const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// Earthquake API URL
const EARTHQUAKE_API_URL = 'https://api.orhanaydogdu.com.tr/deprem';

// Helper function to send FCM notification
async function sendNotification(userId, title, body, data = {}) {
  try {
    // Get user's FCM token from Firestore
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (!userDoc.exists) return;
    
    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;
    
    if (!fcmToken) {
      console.log(`No FCM token for user ${userId}`);
      return;
    }

    // Get user settings
    const settingsDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('settings')
      .doc('app_settings')
      .get();
    
    const settings = settingsDoc.exists ? settingsDoc.data() : {};
    
    // Check if push notifications are enabled
    if (settings.pushNotifications === false) {
      console.log(`Push notifications disabled for user ${userId}`);
      return;
    }

    // Send notification
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: fcmToken,
      android: {
        priority: 'high',
        notification: {
          channelId: data.channel || 'earthquake_channel',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log(`Successfully sent notification to ${userId}: ${response}`);
  } catch (error) {
    console.error(`Error sending notification to ${userId}:`, error);
  }
}

// Helper function to calculate distance between two coordinates
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

// Scheduled function to check for new earthquakes every 5 minutes
exports.checkEarthquakes = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
  console.log('Checking for new earthquakes...');
  
  try {
    // Fetch recent earthquakes from API
    const response = await axios.get(EARTHQUAKE_API_URL, {
      params: {
        limit: 10,
      },
    });

    if (response.data.status !== true || !response.data.result) {
      console.log('Invalid API response');
      return null;
    }

    const earthquakes = response.data.result;
    const now = admin.firestore.Timestamp.now();
    const fiveMinutesAgo = new Date(now.toMillis() - 5 * 60 * 1000);

    // Get all users with FCM tokens
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('fcmToken', '!=', null)
      .get();

    if (usersSnapshot.empty) {
      console.log('No users with FCM tokens found');
      return null;
    }

    // Process each user
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();
      
      // Get user settings
      const settingsDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('app_settings')
        .get();
      
      const settings = settingsDoc.exists ? settingsDoc.data() : {
        pushNotifications: true,
        minMagnitude: 3.0,
        nearbyAlerts: true,
        locationServices: false,
      };

      if (settings.pushNotifications === false) continue;

      // Get user location if available
      let userLocation = null;
      if (settings.locationServices && userData.location) {
        userLocation = userData.location;
      }

      // Check each earthquake
      for (const eq of earthquakes) {
        const eqDate = new Date(eq.date);
        if (eqDate < fiveMinutesAgo) continue; // Skip old earthquakes

        const magnitude = parseFloat(eq.magnitude);
        const minMagnitude = parseFloat(settings.minMagnitude) || 3.0;
        
        // Check if magnitude threshold is met
        let shouldNotify = magnitude >= minMagnitude;
        
        // Check nearby alerts
        if (settings.nearbyAlerts && userLocation) {
          const distance = calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            parseFloat(eq.latitude),
            parseFloat(eq.longitude)
          );
          if (distance <= 200) {
            shouldNotify = true;
          }
        }

        if (!shouldNotify) continue;

        // Check if we already sent notification for this earthquake
        const notificationId = eq.earthquake_id || `${eq.latitude}_${eq.longitude}_${eqDate.getTime()}`;
        const sentNotificationsDoc = await admin.firestore()
          .collection('users')
          .doc(userId)
          .collection('sent_earthquake_notifications')
          .doc(notificationId)
          .get();

        if (sentNotificationsDoc.exists) continue; // Already sent

        // Send notification
        const isMajor = magnitude >= 5.0;
        const title = isMajor ? 'Major Earthquake Alert' : 'Earthquake Detected';
        let body = `M${magnitude.toFixed(1)} earthquake in ${eq.location}`;
        
        if (userLocation) {
          const distance = calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            parseFloat(eq.latitude),
            parseFloat(eq.longitude)
          );
          body += ` - ${distance.toFixed(0)}km away`;
        }

        await sendNotification(userId, title, body, {
          channel: 'earthquake_channel',
          channelName: 'Earthquake Alerts',
          payload: `eq:${notificationId}`,
          earthquakeId: notificationId,
        });

        // Mark as sent
        await admin.firestore()
          .collection('users')
          .doc(userId)
          .collection('sent_earthquake_notifications')
          .doc(notificationId)
          .set({
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            magnitude: magnitude,
            location: eq.location,
          });
      }
    }

    console.log('Earthquake check completed');
    return null;
  } catch (error) {
    console.error('Error checking earthquakes:', error);
    return null;
  }
});

// Trigger when a new post is created
exports.onPostCreated = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    const postId = context.params.postId;
    const authorId = postData.authorId;

    // Get all users who follow this author
    const followersSnapshot = await admin.firestore()
      .collection('users')
      .doc(authorId)
      .collection('followers')
      .get();

    if (followersSnapshot.empty) {
      console.log(`No followers for user ${authorId}`);
      return null;
    }

    // Send notification to each follower
    const promises = followersSnapshot.docs.map(async (followerDoc) => {
      const followerId = followerDoc.id;
      
      // Get follower settings
      const settingsDoc = await admin.firestore()
        .collection('users')
        .doc(followerId)
        .collection('settings')
        .doc('app_settings')
        .get();
      
      const settings = settingsDoc.exists ? settingsDoc.data() : {};
      
      if (settings.communityUpdates === false || settings.pushNotifications === false) {
        return;
      }

      const postType = postData.type === 'safe' ? 'Safety Report' : 'Community Update';
      const message = postData.message || '';
      const body = message.length > 80 
        ? `${postData.authorName}: ${message.substring(0, 80)}...`
        : `${postData.authorName}: ${message}`;

      await sendNotification(followerId, postType, body, {
        channel: 'community_channel',
        channelName: 'Community Updates',
        payload: `post:${postId}`,
        postId: postId,
      });
    });

    await Promise.all(promises);
    console.log(`Sent notifications for post ${postId} to ${followersSnapshot.docs.length} followers`);
    return null;
  });

// Trigger when a user likes a post
exports.onPostLiked = functions.firestore
  .document('posts/{postId}/likes/{userId}')
  .onCreate(async (snap, context) => {
    const postId = context.params.postId;
    const likerId = context.params.userId;

    // Get post data
    const postDoc = await admin.firestore().collection('posts').doc(postId).get();
    if (!postDoc.exists) return null;

    const postData = postDoc.data();
    const authorId = postData.authorId;

    // Don't notify if user liked their own post
    if (authorId === likerId) return null;

    // Get liker's name
    const likerDoc = await admin.firestore().collection('users').doc(likerId).get();
    const likerName = likerDoc.exists ? likerDoc.data().displayName || 'Someone' : 'Someone';

    // Send notification to post author
    await sendNotification(authorId, 'New Like', `${likerName} liked your post`, {
      channel: 'remote_channel',
      channelName: 'General Notifications',
      payload: `post:${postId}`,
      postId: postId,
      type: 'like',
    });

    console.log(`Sent like notification for post ${postId}`);
    return null;
  });

// Trigger when a user comments on a post
exports.onCommentCreated = functions.firestore
  .document('posts/{postId}/comments/{commentId}')
  .onCreate(async (snap, context) => {
    const commentData = snap.data();
    const postId = context.params.postId;
    const commenterId = commentData.authorId;

    // Get post data
    const postDoc = await admin.firestore().collection('posts').doc(postId).get();
    if (!postDoc.exists) return null;

    const postData = postDoc.data();
    const authorId = postData.authorId;

    // Don't notify if user commented on their own post
    if (authorId === commenterId) return null;

    // Get commenter's name
    const commenterDoc = await admin.firestore().collection('users').doc(commenterId).get();
    const commenterName = commenterDoc.exists ? commenterDoc.data().displayName || 'Someone' : 'Someone';

    // Get comment text - try both 'text' and 'message' fields for compatibility
    const commentText = commentData.text || commentData.message || '';
    // Show full comment text in notification (up to 200 characters for notification display)
    const body = commentText.length > 200 
      ? `${commenterName}: ${commentText.substring(0, 200)}...`
      : commentText.length > 0
      ? `${commenterName}: ${commentText}`
      : `${commenterName} commented on your post`;

    // Send notification to post author
    await sendNotification(authorId, 'New Comment', body, {
      channel: 'remote_channel',
      channelName: 'General Notifications',
      payload: `post:${postId}`,
      postId: postId,
      type: 'comment',
    });

    console.log(`Sent comment notification for post ${postId}`);
    return null;
  });

