import 'package:flutter/material.dart';
import 'package:riendzo/views/my_trips/booking/widgets/booking_header.dart';
import 'package:riendzo/views/my_trips/booking/widgets/custom_button.dart';
import '../../../Mock Data/ProfilePictures.dart';
import '../../../settings/online_status_indicator.dart';
import '../../../widgets/Shared Widgets/user_avatar.dart';

class SelectFriends extends StatefulWidget {
  const SelectFriends({super.key});

  @override
  State<SelectFriends> createState() => _SelectFriendsState();
}

class _SelectFriendsState extends State<SelectFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 15),
        child: Column(
          children: [
            const BookingHeader(text: 'Invite Friends to trip', color: Colors.black,),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Stack(
                          children: [
                            UserAvatar(
                              size: 20,
                              picture: profilePictures[index],
                            ),
                            Positioned(
                              child: OnlineStatusIndicator(
                                borderColor: Colors.white,
                                statusColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        title: const Text("Thembi Mkansi"),
                        trailing: Checkbox(
                          isError: true,
                          tristate: true,
                          value: true,
                          fillColor:
                              const WidgetStatePropertyAll(Colors.blueAccent),
                          shape: const CircleBorder(),
                          onChanged: (bool? value) {
                            setState(() {
                              //isChecked = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CustomButton(
                horizontalPadding: 37,
                cardColor: Colors.blueAccent,
                onPressed: () {},
                text: 'Next',
                textColor: Colors.white,
                TextSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
