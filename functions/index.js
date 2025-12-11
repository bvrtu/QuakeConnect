const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const Parser = require('rss-parser');

admin.initializeApp();

// Initialize RSS parser
const parser = new Parser({
  customFields: {
    item: ['media:content', 'enclosure'],
  },
});

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
    
    // After checking earthquakes, also fetch news for recent earthquakes
    try {
      console.log('Triggering news fetch for recent earthquakes...');
      const newsResponse = await axios.get(EARTHQUAKE_API_URL, {
        params: {
          limit: 20,
        },
      });
      
      if (newsResponse.data.status === true && newsResponse.data.result) {
        const nowDate = new Date();
        const recentEqs = newsResponse.data.result
          .filter(eq => {
            const eqDate = eq.date_time ? new Date(eq.date_time) : 
                           eq.date ? new Date(eq.date) : null;
            if (!eqDate) return false;
            const hoursAgo = (nowDate.getTime() - eqDate.getTime()) / (1000 * 60 * 60);
            return hoursAgo <= 24; // Last 24 hours
          })
          .map(eq => ({
            earthquakeId: eq.earthquake_id || `${eq.latitude}_${eq.longitude}_${new Date(eq.date_time || eq.date).getTime()}`,
            location: eq.title || eq.location || 'Unknown',
            dateTime: eq.date_time ? new Date(eq.date_time) : (eq.date ? new Date(eq.date) : new Date()),
            magnitude: parseFloat(eq.mag) || 0,
          }));
        
        if (recentEqs.length > 0) {
          const newsItems = await fetchNewsFromSources();
          await matchNewsWithEarthquakes(recentEqs, newsItems);
        }
      }
    } catch (error) {
      console.error('Error fetching news after earthquake check:', error);
      // Don't throw, just log - news fetching is not critical
    }
    
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

// HTTP callable function to send safety status notifications to emergency contacts
exports.sendSafetyStatusNotifications = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const senderUserId = data.senderUserId;
  const senderName = data.senderName || 'Someone';
  const phoneNumbers = data.phoneNumbers || [];
  const location = data.location || 'Unknown location';
  const timestamp = data.timestamp || new Date().toISOString();

  if (!phoneNumbers || phoneNumbers.length === 0) {
    return { success: false, message: 'No phone numbers provided' };
  }

  try {
    // Normalize phone numbers (remove non-digits)
    const normalizedPhones = phoneNumbers.map(p => p.replace(/\D/g, ''));
    const phoneSet = new Set(normalizedPhones);

    // Get all users with FCM tokens
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('fcmToken', '!=', null)
      .get();

    if (usersSnapshot.empty) {
      return { success: true, notified: 0 };
    }

    const notifiedUsers = [];

    // For each user, check if any of their emergency contacts' phone numbers match
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      
      // Skip the sender
      if (userId === senderUserId) continue;
      
      // Get user's emergency contacts
      const contactsSnapshot = await admin.firestore()
        .collection('users')
        .doc(userId)
        .collection('emergencyContacts')
        .get();
      
      // Check if any emergency contact's phone matches the sender's emergency contacts
      let shouldNotify = false;
      for (const contactDoc of contactsSnapshot.docs) {
        const contactData = contactDoc.data();
        const contactPhone = (contactData.phone || '').replace(/\D/g, '');
        
        // If this user has a contact with a phone number that matches sender's emergency contacts
        if (phoneSet.has(contactPhone)) {
          shouldNotify = true;
          break;
        }
      }
      
      if (shouldNotify) {
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;
        
        if (fcmToken) {
          // Check user settings
          const settingsDoc = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('app_settings')
            .get();
          
          const settings = settingsDoc.exists ? settingsDoc.data() : {};
          
          if (settings.pushNotifications !== false) {
            const body = `${senderName} marked themselves safe. Location: ${location}`;
            
            await sendNotification(userId, 'Safety Status Update', body, {
              channel: 'remote_channel',
              channelName: 'General Notifications',
              type: 'safety_status',
              senderUserId: senderUserId,
              location: location,
              timestamp: timestamp,
            });
            
            notifiedUsers.push(userId);
          }
        }
      }
    }

    return {
      success: true,
      notified: notifiedUsers.length,
      message: `Notifications sent to ${notifiedUsers.length} users`,
    };
  } catch (error) {
    console.error('Error sending safety status notifications:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notifications', error);
  }
});

// Trusted news sources RSS feeds
const NEWS_SOURCES = [
  {
    name: 'BBC Türkçe',
    url: 'https://www.bbc.com/turkce/haberler/rss.xml',
    keywords: ['deprem', 'earthquake', 'sarsıntı', 'tremor'],
  },
  {
    name: 'CNN Türk',
    url: 'https://www.cnnturk.com/feed/rss/turkiye/news',
    keywords: ['deprem', 'earthquake', 'sarsıntı', 'tremor'],
  },
  {
    name: 'Anadolu Ajansı',
    url: 'https://www.aa.com.tr/tr/rss/default?cat=guncel',
    keywords: ['deprem', 'earthquake', 'sarsıntı', 'tremor'],
  },
  {
    name: 'NTV',
    url: 'https://www.ntv.com.tr/gundem.rss',
    keywords: ['deprem', 'earthquake', 'sarsıntı', 'tremor'],
  },
  {
    name: 'Hürriyet',
    url: 'https://www.hurriyet.com.tr/rss/gundem',
    keywords: ['deprem', 'earthquake', 'sarsıntı', 'tremor'],
  },
];

// Helper function to extract location from earthquake data
function extractLocationKeywords(location) {
  // Extract city/region names from location string
  // Example: "EGE DENIZI, IZMIR" -> ["izmir", "ege", "deniz"]
  const words = location.toLowerCase()
    .replace(/[^a-zçğıöşü\s]/g, '')
    .split(/\s+/)
    .filter(w => w.length > 2);
  
  // Also add common location variations
  const variations = [];
  for (const word of words) {
    variations.push(word);
    // Add variations for common Turkish city names
    if (word === 'izmir') variations.push('izmir');
    if (word === 'istanbul') variations.push('istanbul');
    if (word === 'ankara') variations.push('ankara');
    if (word === 'antalya') variations.push('antalya');
    if (word === 'balikesir') variations.push('balıkesir', 'balikesir');
    if (word === 'balıkesir') variations.push('balikesir', 'balıkesir');
  }
  
  return variations;
}

// Helper function to extract magnitude from text
function extractMagnitudeFromText(text) {
  // Match patterns like "4.9", "4,9", "4.9 büyüklüğünde", "magnitude 4.9", etc.
  const magnitudePatterns = [
    /(\d+[.,]\d+)\s*(?:büyüklüğünde|magnitude|şiddetinde|richter|ml|ml\s*=|magnitude\s*=|magnitude\s*of)/i,
    /(?:büyüklüğü|magnitude|şiddet|richter|ml)\s*(?:[:=]?\s*)?(\d+[.,]\d+)/i,
    /(\d+[.,]\d+)\s*(?:büyüklüğü|magnitude|şiddet|richter|ml)/i,
  ];
  
  for (const pattern of magnitudePatterns) {
    const match = text.match(pattern);
    if (match) {
      const magnitudeStr = match[1].replace(',', '.');
      const magnitude = parseFloat(magnitudeStr);
      if (!isNaN(magnitude) && magnitude >= 1.0 && magnitude <= 10.0) {
        return magnitude;
      }
    }
  }
  
  // Also try simple number patterns near earthquake keywords
  const simplePattern = /(?:deprem|earthquake|sarsıntı).*?(\d+[.,]\d+)/i;
  const simpleMatch = text.match(simplePattern);
  if (simpleMatch) {
    const magnitudeStr = simpleMatch[1].replace(',', '.');
    const magnitude = parseFloat(magnitudeStr);
    if (!isNaN(magnitude) && magnitude >= 1.0 && magnitude <= 10.0) {
      return magnitude;
    }
  }
  
  return null;
}

// Helper function to check if news article is related to earthquake
function isRelatedToEarthquake(newsItem, earthquake) {
  const title = (newsItem.title || '').toLowerCase();
  const content = (newsItem.contentSnippet || newsItem.content || '').toLowerCase();
  const combined = title + ' ' + content;
  const combinedOriginal = (newsItem.title || '') + ' ' + (newsItem.contentSnippet || newsItem.content || '');
  
  // Strong earthquake keywords (must include at least one)
  const strongKeywords = ['deprem', 'earthquake', 'sarsıntı'];
  // Weak keywords (can be used but not sufficient alone)
  const weakKeywords = ['tremor', 'şiddet', 'magnitude', 'richter', 'afet', 'yer sarsıntısı'];
  
  // Check for strong earthquake keywords first
  const hasStrongKeyword = strongKeywords.some(keyword => combined.includes(keyword));
  
  // If no strong keyword, check if it has multiple weak keywords
  const weakKeywordCount = weakKeywords.filter(keyword => combined.includes(keyword)).length;
  const hasMultipleWeakKeywords = weakKeywordCount >= 2;
  
  // Must have either strong keyword or multiple weak keywords
  if (!hasStrongKeyword && !hasMultipleWeakKeywords) {
    return false;
  }
  
  // Extract magnitude from news if available
  const newsMagnitude = extractMagnitudeFromText(combinedOriginal);
  
  // Check for location match (REQUIRED)
  const locationKeywords = extractLocationKeywords(earthquake.location);
  const hasLocationMatch = locationKeywords.length > 0 && 
    locationKeywords.some(keyword => combined.includes(keyword));
  
  // Location match is ALWAYS required
  if (!hasLocationMatch) {
    return false;
  }
  
  // Magnitude matching logic
  if (newsMagnitude !== null) {
    // If news mentions a specific magnitude, it MUST match the earthquake magnitude
    // Account for AFAD/Kandilli difference (tolerance: ±0.3)
    const magnitudeDiff = Math.abs(newsMagnitude - earthquake.magnitude);
    // If magnitude difference is more than 0.3, it's likely a different earthquake
    if (magnitudeDiff > 0.3) {
      return false;
    }
    // Magnitude matches within tolerance, proceed
  } else {
    // News doesn't mention magnitude - only accept for major earthquakes (>= 4.5)
    // and only if location matches (which we already checked)
    if (earthquake.magnitude < 4.5) {
      // For smaller earthquakes, magnitude must be mentioned in news
      return false;
    }
    // For major earthquakes (>= 4.5), location match is sufficient if magnitude not mentioned
  }
  
  // Check time proximity (news should be within 12 hours of earthquake for better accuracy)
  const newsDate = newsItem.pubDate ? new Date(newsItem.pubDate) : null;
  if (newsDate) {
    const earthquakeDate = earthquake.dateTime ? new Date(earthquake.dateTime) : new Date();
    const timeDiff = Math.abs(newsDate - earthquakeDate);
    const hoursDiff = timeDiff / (1000 * 60 * 60);
    // Stricter time window: 12 hours instead of 24
    if (hoursDiff > 12) return false;
  }
  
  // Exclude unrelated news by checking for negative keywords
  const negativeKeywords = ['sis', 'pus', 'kar', 'yağmur', 'fırtına', 'hava', 'meteoroloji', 
                            'weather', 'fog', 'snow', 'rain', 'storm', 'temperature'];
  const hasNegativeKeyword = negativeKeywords.some(keyword => combined.includes(keyword));
  
  // If has negative keyword and no strong earthquake context, exclude
  if (hasNegativeKeyword && !hasStrongKeyword) {
    return false;
  }
  
  // Final check: 
  // 1. Must have earthquake keyword
  // 2. Location must match (already checked above)
  // 3. If magnitude is mentioned in news, it must match earthquake magnitude (already checked above)
  // 4. If magnitude is NOT mentioned, only accept for major earthquakes (>= 4.5) (already checked above)
  return (hasStrongKeyword || hasMultipleWeakKeywords);
}

// Helper function to fetch and parse RSS feeds
async function fetchNewsFromSources() {
  const allNews = [];
  
  for (const source of NEWS_SOURCES) {
    try {
      console.log(`Fetching news from ${source.name}...`);
      const feed = await parser.parseURL(source.url);
      
      if (feed.items && feed.items.length > 0) {
        for (const item of feed.items) {
          allNews.push({
            title: item.title || '',
            url: item.link || '',
            source: source.name,
            publishedAt: item.pubDate ? new Date(item.pubDate) : new Date(),
            content: item.contentSnippet || item.content || '',
            imageUrl: item.enclosure?.url || item['media:content']?.$.url || null,
            pubDate: item.pubDate,
            contentSnippet: item.contentSnippet || item.content || '',
          });
        }
      }
    } catch (error) {
      console.error(`Error fetching news from ${source.name}:`, error.message);
    }
  }
  
  return allNews;
}

// Function to match news with earthquakes and save to Firestore
async function matchNewsWithEarthquakes(earthquakes, newsItems) {
  const db = admin.firestore();
  let matchedCount = 0;
  
  console.log(`Matching ${newsItems.length} news items with ${earthquakes.length} earthquakes...`);
  
  for (const earthquake of earthquakes) {
    if (!earthquake.earthquakeId) continue;
    
    // Find related news
    const relatedNews = newsItems.filter(news => {
      const isRelated = isRelatedToEarthquake(news, earthquake);
      if (isRelated) {
        console.log(`Found match: "${news.title.substring(0, 50)}..." for earthquake ${earthquake.earthquakeId} (${earthquake.magnitude} in ${earthquake.location})`);
      }
      return isRelated;
    });
    
    if (relatedNews.length === 0) {
      console.log(`No news found for earthquake ${earthquake.earthquakeId} (${earthquake.magnitude} in ${earthquake.location})`);
      continue;
    }
    
    console.log(`Found ${relatedNews.length} related news for earthquake ${earthquake.earthquakeId}`);
    
    // Check if news already exists for this earthquake
    const existingNewsSnapshot = await db
      .collection('earthquake_news')
      .doc(earthquake.earthquakeId)
      .collection('articles')
      .get();
    
    const existingUrls = new Set(existingNewsSnapshot.docs.map(doc => doc.data().url));
    
    // Add new news articles
    for (const news of relatedNews) {
      // Skip if already exists
      if (existingUrls.has(news.url)) continue;
      
      try {
        await db
          .collection('earthquake_news')
          .doc(earthquake.earthquakeId)
          .collection('articles')
          .add({
            title: news.title,
            url: news.url,
            source: news.source,
            publishedAt: admin.firestore.Timestamp.fromDate(news.publishedAt),
            imageUrl: news.imageUrl,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        
        matchedCount++;
        console.log(`Added news "${news.title}" for earthquake ${earthquake.earthquakeId}`);
      } catch (error) {
        console.error(`Error adding news for earthquake ${earthquake.earthquakeId}:`, error);
      }
    }
  }
  
  return matchedCount;
}

// HTTP callable function to manually trigger news fetch (for pull-to-refresh)
exports.fetchEarthquakeNewsManual = functions.https.onCall(async (data, context) => {
  console.log('Manual news fetch triggered from app...');
  
  try {
    // Fetch recent earthquakes from API (last 24 hours)
    const response = await axios.get(EARTHQUAKE_API_URL, {
      params: {
        limit: 50,
      },
    });

    if (response.data.status !== true || !response.data.result) {
      console.log('Invalid API response');
      return { success: false, message: 'Invalid API response' };
    }

    const earthquakes = response.data.result;
    
    // Filter earthquakes from last 24 hours and format them
    const now = new Date();
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    
    const recentEarthquakes = earthquakes
      .filter(eq => {
        const eqDate = eq.date_time ? new Date(eq.date_time) : 
                       eq.date ? new Date(eq.date) : null;
        return eqDate && eqDate >= yesterday;
      })
      .map(eq => ({
        earthquakeId: eq.earthquake_id || `${eq.latitude}_${eq.longitude}_${new Date(eq.date_time || eq.date).getTime()}`,
        location: eq.title || eq.location || 'Unknown',
        dateTime: eq.date_time ? new Date(eq.date_time) : (eq.date ? new Date(eq.date) : new Date()),
        magnitude: parseFloat(eq.mag) || 0,
      }));
    
    console.log(`Found ${recentEarthquakes.length} recent earthquakes`);
    
    if (recentEarthquakes.length === 0) {
      console.log('No recent earthquakes to match with news');
      return { success: true, matched: 0, message: 'No recent earthquakes' };
    }
    
    // Fetch news from all sources
    const newsItems = await fetchNewsFromSources();
    console.log(`Fetched ${newsItems.length} news items from all sources`);
    
    // Match news with earthquakes
    const matchedCount = await matchNewsWithEarthquakes(recentEarthquakes, newsItems);
    
    console.log(`Matched and saved ${matchedCount} news articles`);
    
    return {
      success: true,
      matched: matchedCount,
      earthquakesChecked: recentEarthquakes.length,
      message: `Matched ${matchedCount} news articles`,
    };
  } catch (error) {
    console.error('Error in manual news fetch:', error);
    throw new functions.https.HttpsError('internal', 'Error fetching news', error);
  }
});

// Scheduled function to fetch news and match with earthquakes (runs every 5 minutes)
exports.fetchEarthquakeNews = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
  console.log('Fetching earthquake news from trusted sources...');
  
  try {
    // Fetch recent earthquakes from API (last 24 hours)
    const response = await axios.get(EARTHQUAKE_API_URL, {
      params: {
        limit: 50, // Get more earthquakes to match with
      },
    });

    if (response.data.status !== true || !response.data.result) {
      console.log('Invalid API response');
      return null;
    }

    const earthquakes = response.data.result;
    
    // Filter earthquakes from last 24 hours and format them
    const now = new Date();
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    
    const recentEarthquakes = earthquakes
      .filter(eq => {
        const eqDate = eq.date_time ? new Date(eq.date_time) : 
                       eq.date ? new Date(eq.date) : null;
        return eqDate && eqDate >= yesterday;
      })
      .map(eq => ({
        earthquakeId: eq.earthquake_id || `${eq.latitude}_${eq.longitude}_${new Date(eq.date_time || eq.date).getTime()}`,
        location: eq.title || eq.location || 'Unknown',
        dateTime: eq.date_time ? new Date(eq.date_time) : (eq.date ? new Date(eq.date) : new Date()),
        magnitude: parseFloat(eq.mag) || 0,
      }));
    
    console.log(`Found ${recentEarthquakes.length} recent earthquakes`);
    
    if (recentEarthquakes.length === 0) {
      console.log('No recent earthquakes to match with news');
      return null;
    }
    
    // Fetch news from all sources
    const newsItems = await fetchNewsFromSources();
    console.log(`Fetched ${newsItems.length} news items from all sources`);
    
    // Match news with earthquakes
    const matchedCount = await matchNewsWithEarthquakes(recentEarthquakes, newsItems);
    
    console.log(`Matched and saved ${matchedCount} news articles`);
    
    return {
      success: true,
      earthquakesChecked: recentEarthquakes.length,
      newsFetched: newsItems.length,
      newsMatched: matchedCount,
    };
  } catch (error) {
    console.error('Error fetching earthquake news:', error);
    throw error;
  }
});

// Function to manually trigger news fetching (for testing)
exports.triggerNewsFetch = functions.https.onCall(async (data, context) => {
  // Optional: Add authentication check here
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  // }
  
  console.log('Manually triggering news fetch...');
  
  try {
    // Fetch recent earthquakes
    const response = await axios.get(EARTHQUAKE_API_URL, {
      params: {
        limit: 50,
      },
    });

    if (response.data.status !== true || !response.data.result) {
      return { success: false, message: 'Invalid API response' };
    }

    const earthquakes = response.data.result;
    const now = new Date();
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    
    const recentEarthquakes = earthquakes
      .filter(eq => {
        const eqDate = eq.date_time ? new Date(eq.date_time) : 
                       eq.date ? new Date(eq.date) : null;
        return eqDate && eqDate >= yesterday;
      })
      .map(eq => ({
        earthquakeId: eq.earthquake_id || `${eq.latitude}_${eq.longitude}_${new Date(eq.date_time || eq.date).getTime()}`,
        location: eq.title || eq.location || 'Unknown',
        dateTime: eq.date_time ? new Date(eq.date_time) : (eq.date ? new Date(eq.date) : new Date()),
        magnitude: parseFloat(eq.mag) || 0,
      }));
    
    // Fetch news
    const newsItems = await fetchNewsFromSources();
    
    // Match and save
    const matchedCount = await matchNewsWithEarthquakes(recentEarthquakes, newsItems);
    
    return {
      success: true,
      earthquakesChecked: recentEarthquakes.length,
      newsFetched: newsItems.length,
      newsMatched: matchedCount,
      message: `Successfully matched ${matchedCount} news articles`,
    };
  } catch (error) {
    console.error('Error in manual news fetch:', error);
    throw new functions.https.HttpsError('internal', 'Error fetching news', error);
  }
});

