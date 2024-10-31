import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:riendzo/views/my_trips/booking/widgets/CustomBookingDropdown.dart';
import 'package:riendzo/views/my_trips/booking/widgets/booking_header.dart';
import 'package:riendzo/views/my_trips/booking/widgets/custom_button.dart';
import 'package:riendzo/views/my_trips/booking/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../widgets/Shared Widgets/friendsSelection.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _budgetController = TextEditingController();
  String? _selectedInterest;
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _datesController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  final DateFormat dateFormat = DateFormat('dd MMM');



  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  bool isSoloSelected = true; // Boolean to track selected option


  Future<List<String>> getSuggestions(String query) async {
    final apiKey = 'AIzaSyBS6FrbtuEV7MD2GsyZ7lkFehwLDo_U7BY'; // Replace with your API key
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final predictions = json['predictions'] as List;
      return predictions.map((p) => p['description'] as String).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
  Future<void> _saveTripToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_isLoading) return;

    // Check if destination is provided
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    // Check if trip name is provided
    if (_tripNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a trip name')),
      );
      return;
    }

    // Check if budget is provided and is a valid number
    if (_budgetController.text.isEmpty || double.tryParse(_budgetController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget')),
      );
      return;
    }

    // Check if date range is provided
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range')),
      );
      return;
    }

    // Extract and format start and end dates
    final DateTime startDate = _selectedDateRange!.start;
    final DateTime endDate = _selectedDateRange!.end;
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy");

    // Validate that endDate is after startDate and not today or earlier
    final DateTime now = DateTime.now();
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after the start date and cannot be today')),
      );
      return;
    }

    // Check if an image is selected
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String imageUrl = '';
    if (_selectedImage != null) {
      try {
        imageUrl = await _uploadImageToFirebaseStorage(_selectedImage!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    CollectionReference trips = FirebaseFirestore.instance.collection('trips');
    try {
      await trips.add({
        'userId': user?.uid,
        'destination': _destinationController.text,
        'startDate': dateFormat.format(startDate),
        'endDate': dateFormat.format(endDate),
        'budget': "\$${_budgetController.text}", // Save budget with $
        'interest': _selectedInterest,
        'tripName': _tripNameController.text,
        'description': _descriptionController.text,
        'imagePath': imageUrl,
        'status': 'ongoing',
        'travelType': isSoloSelected ? 'Solo' : 'Friends', // Save travel type
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving trip data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<String> _uploadImageToFirebaseStorage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("trip_images/${DateTime
        .now()
        .millisecondsSinceEpoch}");
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
    _budgetController.dispose();
    _tripNameController.dispose();
    _destinationController.dispose();
    _datesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15, top: 10),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BookingHeader(
                  text: 'Trip Information',
                  color: Colors.black,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "I want to go to...",
                      style: TextStyle(color: Colors.black),
                    ),
                    TypeAheadField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _destinationController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 23,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter destination",
                          hintStyle: TextStyle(color: Colors.black),

                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.isNotEmpty) {
                          return await getSuggestions(pattern);
                        }
                        return [];
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        // Update the search bar with the selected suggestion
                        _destinationController.text = suggestion;
                      },
                    ),
                  ],

                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTimeRange? pickedRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(), // Disable past dates
                      lastDate: DateTime(2030),
                      initialDateRange: DateTimeRange(
                        start: DateTime.now(),
                        end: DateTime.now().add(const Duration(days: 7)),
                      ),
                    );

                    if (pickedRange != null) {
                      _datesController.text = '${dateFormat.format(pickedRange.start)} - ${dateFormat.format(pickedRange.end)}';
                      _selectedDateRange = pickedRange; // Save the selected date range
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomBookingTextField(
                      controller: _datesController,
                      icon: Icons.calendar_today_outlined,
                      text: 'Dates',
                      hintText: 'Select date range',
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                    ),
                  ),
                ),




                const SizedBox(height: 1),
                CustomBookingTextField(
                  controller: _budgetController,
                  icon: Icons.attach_money,
                  text: 'Budget per person per day',
                  hintText: 'Enter your budget',
                  keyboardType: TextInputType.number,
                  readOnly: false,
                ),
                CustomBookingDropdown(
                  interests: [
                    "Adventure", "Beaches", "Culture", "Cuisine", "Exploration",
                    "Festivals", "Hiking", "History", "Relaxation", "Safari",
                    "Scenery", "Sports", "Wildlife", "Cruises", "Mountains",
                    "Photography", "Roadtrips", "Shopping", "Spa", "Waterfalls",
                  ],
                  selectedInterest: _selectedInterest,
                  onChanged: (value) {
                    setState(() {
                      _selectedInterest = value;
                    });
                  },
                  icon: Icons.favorite_outline,
                  hintText: 'Choose your interest',
                ),
                CustomBookingTextField(
                  controller: _tripNameController,
                  icon: Icons.trip_origin_outlined,
                  text: 'Trip Name',
                  hintText: 'e.g. Summer Vacation',
                  keyboardType: TextInputType.text,
                  readOnly: false,
                ),
                CustomBookingTextField(
                  controller: _descriptionController,
                  icon: Icons.description_outlined,
                  text: 'Trip Description',
                  hintText: 'Trip Description',
                  keyboardType: TextInputType.multiline,
                  readOnly: false,
                ),
                const SizedBox(height: 5),

                // Image upload section
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      image: _selectedImage != null
                          ? DecorationImage(
                          image: FileImage(_selectedImage!), fit: BoxFit.cover)
                          : _imageUrl != null && _imageUrl!.isNotEmpty
                          ? DecorationImage(
                          image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _selectedImage == null && _imageUrl == null
                        ? const Center(child: Text('Upload a photo'))
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 10),

                // Travel type section
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: const Text('Travel with ?'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomButton(
                      horizontalPadding: 11.5,
                      cardColor: isSoloSelected ? Colors.blueAccent : Colors
                          .white,
                      onPressed: () {
                        setState(() {
                          isSoloSelected = true;
                        });
                      },
                      text: "Solo",
                      textColor: isSoloSelected ? Colors.white : Colors.blue,
                      TextSize: 16.5,
                    ),
                    CustomButton(
                      horizontalPadding: 5,
                      cardColor: !isSoloSelected ? Colors.blueAccent : Colors
                          .white,
                      onPressed: () {
                        setState(() {
                          isSoloSelected = false;
                        });
                        // Navigate to the friends selection screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              context) => const FriendsSelectionPage()),
                        );
                      },
                      text: "With Friends",
                      textColor: !isSoloSelected ? Colors.white : Colors.blue,
                      TextSize: 16.5,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Save button
                Container(
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: CustomButton(
                    horizontalPadding: 28,
                    cardColor: Colors.blueAccent,
                    onPressed: _isLoading ? null : _saveTripToFirebase, // Disable button if loading
                    text: _isLoading
                        ? "Saving..."
                        : "Save", // Change text while loading

                    textColor: Colors.white,
                    TextSize: 16.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



