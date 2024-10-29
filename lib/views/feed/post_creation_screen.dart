import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_player/video_player.dart';

class PostCreationScreen extends StatefulWidget {
  final List<XFile> media;
  const PostCreationScreen({Key? key, required this.media}) : super(key: key);

  @override
  _PostCreationScreenState createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<XFile> _selectedMedia = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool _isPosting = false;
  List<VideoPlayerController?> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _selectedMedia.addAll(widget.media);
    _initializeVideoControllers();
  }

  // Initialize video controllers
  void _initializeVideoControllers() {
    _videoControllers = _selectedMedia.map((file) {
      if (file.path.endsWith(".mp4")) {
        return VideoPlayerController.file(File(file.path))..initialize();
      }
      return null;
    }).toList();
  }

  // Compress image
  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      filePath,
      filePath.replaceAll('.jpg', '_compressed.jpg'),
      quality: 70,
    );
    return compressedImage ?? file;
  }

  // Upload file to Firebase Storage with metadata
  Future<String> _uploadFileToStorage(XFile file) async {
    try {
      File mediaFile = File(file.path);

      if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg') || file.path.endsWith('.png')) {
        mediaFile = await _compressImage(mediaFile);
      }

      Reference ref = _firebaseStorage
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}');

      SettableMetadata metadata = SettableMetadata(
        cacheControl: 'max-age=60',
        contentType: file.path.endsWith('.mp4') ? 'video/mp4' : 'image/jpeg',
      );

      UploadTask uploadTask = ref.putFile(mediaFile, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }

  // Add post to Firestore
  Future<void> _addPostToFirebase(List<String> mediaUrls) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await _firestore.collection('posts').add({
      'content': _textController.text,
      'mediaUrls': mediaUrls,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'likeCount': 0,
    });
  }

  // Upload media and add post
  Future<void> _addPost() async {
    if (_selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one photo or video.')));
      return;
    }

    setState(() => _isPosting = true);
    List<String> mediaUrls = [];
    for (var media in _selectedMedia) {
      final url = await _uploadFileToStorage(media);
      if (url.isNotEmpty) mediaUrls.add(url);
    }

    await _addPostToFirebase(mediaUrls);
    setState(() {
      _isPosting = false;
      _selectedMedia.clear();
    });
    Navigator.pop(context);
  }

  Future<void> _pickMedia() async {
    if (_selectedMedia.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can upload up to 5 items only.')));
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // Only works for images
    // Add video selection if needed by using picker.pickVideo()

    setState(() {
      _selectedMedia.addAll(pickedFiles.take(5 - _selectedMedia.length));
      _initializeVideoControllers();
    });
  }

  // Remove media
  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
      _videoControllers[index]?.dispose();
      _videoControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(hintText: "What's on your mind?"),
                maxLines: null,
              ),
              SizedBox(height: 16.0),
              if (_selectedMedia.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _selectedMedia.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final file = _selectedMedia[index];
                    return Stack(
                      children: [
                        file.path.endsWith(".mp4") && _videoControllers[index] != null
                            ? VideoPlayer(_videoControllers[index]!)
                            : Image.file(File(file.path), fit: BoxFit.cover),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeMedia(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isPosting ? null : _addPost,
                    child: _isPosting ? CircularProgressIndicator(color: Colors.white) : Text('Post'),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: _pickMedia,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
