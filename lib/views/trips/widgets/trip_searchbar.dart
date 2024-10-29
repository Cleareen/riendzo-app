import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchCard extends StatefulWidget {
  final DateTimeRange? selectedDateRange;
  final ValueChanged<DateTimeRange?> onDateRangeSelected;
  final ValueChanged<String> onSearch;

  const SearchCard({
    Key? key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
    required this.onSearch,
  }) : super(key: key);

  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  final TextEditingController _destinationController = TextEditingController();
  String _selectedTripType = 'Solo'; // Default value for trip type

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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Field with Autocomplete
            const Text('Destination', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TypeAheadField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _destinationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter a destination',
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
            const SizedBox(height: 16),

            // Date Range Picker and Trip Type Dropdown
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dates', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          DateTimeRange? pickedRange =
                              await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                            initialDateRange: widget.selectedDateRange ??
                                DateTimeRange(
                                  start: DateTime.now(),
                                  end: DateTime.now()
                                      .add(const Duration(days: 7)),
                                ),
                          );

                          if (pickedRange != null) {
                            widget.onDateRangeSelected(pickedRange);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            widget.selectedDateRange != null
                                ? '${dateFormat.format(widget.selectedDateRange!.start)} - ${dateFormat.format(widget.selectedDateRange!.end)}'
                                : 'Select a date',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trip Type',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTripType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Group', child: Text('Solo')),
                          DropdownMenuItem(value: 'Solo', child: Text('Group')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTripType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Button
            // Search Button
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity, // Makes the button take full width
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSearch(_destinationController.text); // Accessing onSearch from widget
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12), // Adjust padding
                    backgroundColor: Colors.blueAccent, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
