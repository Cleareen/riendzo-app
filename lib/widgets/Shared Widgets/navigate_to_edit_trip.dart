import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riendzo/views/my_trips/booking/widgets/booking_header.dart';
import 'package:riendzo/views/my_trips/booking/widgets/custom_button.dart';
import 'package:riendzo/views/my_trips/booking/widgets/custom_text_field.dart';

class EditTripScreen extends StatefulWidget {
  final String tripId; // The ID of the trip to edit
  const EditTripScreen({super.key, required this.tripId});

  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  File? _selectedImage;
  String? _imageUrl;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTripData();
  }

  // Fetch trip data from Firebase Firestore
  Future<void> _fetchTripData() async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (tripSnapshot.exists) {
        Map<String, dynamic> data = tripSnapshot.data() as Map<String, dynamic>;
        _destinationController.text = data['destination'] ?? '';
        _startDateController.text = data['startDate'] ?? '';
        _endDateController.text = data['endDate'] ?? '';
        _dateController.text = data['date'] ?? '';
        _budgetController.text = data['budget'] ?? '';
        _interestController.text = data['interest'] ?? '';
        _tripNameController.text = data['tripName'] ?? '';
        _imageUrl = data['imagePath'];
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trip data: $e')),
      );
    }
  }

  // Update trip in Firebase
  Future<void> _updateTripInFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to edit a trip.')),
      );
      return;
    }

    if (_startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        _tripNameController.text.isEmpty ||
        _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Ensure end date is not today
    if (DateTime.parse(_endDateController.text).isAtSameMomentAs(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End date cannot be today.')),
      );
      return;
    }

    String imageUrl = _imageUrl ?? '';
    if (_selectedImage != null) {
      try {
        imageUrl = await _uploadImageToFirebaseStorage(_selectedImage!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).update({
        'userId': user.uid,
        'destination': _destinationController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'date': _dateController.text,
        'budget': _budgetController.text,
        'interest': _interestController.text,
        'tripName': _tripNameController.text,
        'imagePath': imageUrl,
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating trip data: $e')),
      );
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImageToFirebaseStorage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("trip_images/${DateTime.now().millisecondsSinceEpoch}");
    SettableMetadata metadata = SettableMetadata(
      cacheControl: 'max-age=60',
      contentType: 'image/jpeg',
    );

    try {
      UploadTask uploadTask = ref.putFile(image, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _dateController.dispose();
    _budgetController.dispose();
    _interestController.dispose();
    _tripNameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with background image and destination input
          Container(
            padding: const EdgeInsets.only(left: 15, top: 20),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .3,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.pexels.com/photos/2341830/pexels-photo-2341830.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BookingHeader(
                  text: 'Edit Trip Information',
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "I want to go to...",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: _destinationController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Enter destination",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Form fields and image picker
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView(
                children: [
                  CustomBookingTextField(
                    controller: _startDateController,
                    icon: Icons.calendar_today,
                    text: 'Start Date',
                    hintText: 'Enter start date',
                    keyboardType: TextInputType.datetime, readOnly: false,
                  ),
                  CustomBookingTextField(
                    controller: _endDateController,
                    icon: Icons.calendar_today,
                    text: 'End Date',
                    hintText: 'Enter end date',
                    keyboardType: TextInputType.datetime, readOnly: false,
                  ),
                  CustomBookingTextField(
                    controller: _budgetController,
                    icon: Icons.money_outlined,
                    text: 'Budget per person per day',
                    hintText: 'Enter your budget',
                    keyboardType: TextInputType.number, readOnly: false,
                  ),
                  CustomBookingTextField(
                    controller: _interestController,
                    icon: Icons.favorite_border,
                    text: 'Choose your interest',
                    hintText: 'e.g. Beach, Hiking',
                    keyboardType: TextInputType.text, readOnly: false,
                  ),
                  CustomBookingTextField(
                    controller: _tripNameController,
                    text: 'Trip Name',
                    hintText: 'e.g. Vacation 2024',
                    keyboardType: TextInputType.text, readOnly: false,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15),
                          image: _selectedImage != null
                              ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                              : _imageUrl != null
                              ? DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _selectedImage == null && _imageUrl == null
                            ? const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.blue,
                          ),
                        )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CustomButton(
              horizontalPadding: 15,
              cardColor: Colors.blueAccent,
              onPressed: _updateTripInFirebase,
              text: "Update",
              textColor: Colors.white,
              TextSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
