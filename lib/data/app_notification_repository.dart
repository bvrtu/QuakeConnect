import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/user_repository.dart';

class AppNotificationRepository {
  static final AppNotificationRepository instance = AppNotificationRepository._();
  AppNotificationRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendLikeNotification({
    required String postAuthorId,
    required String likerId,
    required String postId,
  }) async {
    if (postAuthorId == likerId) return;
    
    final user = await UserRepository.instance.getUser(likerId);
    final name = user?.username ?? 'Someone';

    await _sendNotification(
      recipientId: postAuthorId,
      senderId: likerId,
      type: 'like',
      postId: postId,
      title: 'New Like',
      body: '$name liked your post',
    );
  }

  Future<void> sendRepostNotification({
    required String postAuthorId,
    required String reposterId,
    required String postId,
  }) async {
    if (postAuthorId == reposterId) return;

    final user = await UserRepository.instance.getUser(reposterId);
    final name = user?.username ?? 'Someone';

    await _sendNotification(
      recipientId: postAuthorId,
      senderId: reposterId,
      type: 'repost',
      postId: postId,
      title: 'New Repost',
      body: '$name reposted your post',
    );
  }

  Future<void> sendCommentNotification({
    required String postAuthorId,
    required String commenterId,
    required String postId,
    required String commentText,
  }) async {
    if (postAuthorId == commenterId) return;

    final user = await UserRepository.instance.getUser(commenterId);
    final name = user?.username ?? 'Someone';

    await _sendNotification(
      recipientId: postAuthorId,
      senderId: commenterId,
      type: 'comment',
      postId: postId,
      title: 'New Comment',
      body: '$name commented: $commentText',
    );
  }

  Future<void> sendReplyNotification({
    required String commentAuthorId,
    required String replierId,
    required String postId,
    required String replyText,
  }) async {
    if (commentAuthorId == replierId) return;

    final user = await UserRepository.instance.getUser(replierId);
    final name = user?.username ?? 'Someone';

    await _sendNotification(
      recipientId: commentAuthorId,
      senderId: replierId,
      type: 'reply',
      postId: postId,
      title: 'New Reply',
      body: '$name replied: $replyText',
    );
  }

  Future<void> _sendNotification({
    required String recipientId,
    required String senderId,
    required String type,
    String? postId,
    required String title,
    required String body,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .add({
        'type': type,
        'senderId': senderId,
        'postId': postId,
        'title': title,
        'body': body,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore errors for notifications to avoid blocking flow
      print('Error sending notification: $e');
    }
  }
}

