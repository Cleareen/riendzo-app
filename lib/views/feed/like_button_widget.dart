import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Post.dart';

class LikeButtonWidget extends StatefulWidget {
  final PostModel post;

  LikeButtonWidget({required this.post});

  @override
  _LikeButtonWidgetState createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likeCount = widget.post.likeCount;

    // Listen for real-time updates to likeCount
    FirebaseDatabase.instance
        .ref('posts/${widget.post.postId}/likeCount')
        .onValue
        .listen((event) {
      final newLikeCount = event.snapshot.value as int;
      setState(() {
        likeCount = newLikeCount;
      });
    });
  }

  void _toggleLike() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final likeRef = FirebaseDatabase.instance
        .ref('posts/${widget.post.postId}/likes/${currentUser.uid}');

    final likeSnapshot = await likeRef.get();
    final wasLiked = likeSnapshot.exists && likeSnapshot.value == true;

    if (wasLiked) {
      // Already liked, so remove like
      await likeRef.remove();
      await FirebaseDatabase.instance
          .ref('posts/${widget.post.postId}/likeCount')
          .set(likeCount - 1);
      setState(() {
        isLiked = false;
        likeCount -= 1;
      });
    } else {
      // Not yet liked, so add like
      await likeRef.set(true);
      await FirebaseDatabase.instance
          .ref('posts/${widget.post.postId}/likeCount')
          .set(likeCount + 1);
      setState(() {
        isLiked = true;
        likeCount += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: _toggleLike,
          child: Container(
            decoration: BoxDecoration(
              color: isLiked
                  ? Colors.red[100]!.withOpacity(0.8)
                  : Colors.grey[200]!.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red.withOpacity(0.9) : Colors.grey,
                  ),
                  SizedBox(width: 5.0),
                  Text(
                    '$likeCount likes',
                    style: TextStyle(
                      fontSize: 14,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
