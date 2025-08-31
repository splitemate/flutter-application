import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/user.dart';

class FriendAddedDialog extends StatelessWidget {
  final User friend;
  final bool isAlreadyFriend;
  final VoidCallback onClose;

  const FriendAddedDialog({
    super.key,
    required this.friend,
    required this.isAlreadyFriend,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: size.width * 0.85,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon and gradient background
            Container(
              height: size.height * 0.15,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: kGradColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Container(
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(size.width * 0.06),
              child: Column(
                children: [
                  Text(
                    isAlreadyFriend
                        ? 'Friend Found! 👋'
                        : 'Friend Added Successfully! 🎉',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GT-Walsheim-Pro',
                      color: kBlackColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Friend details card
                  Container(
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: kStockColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: kGradColors[0].withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Friend avatar
                        Container(
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: kGradColors,
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: size.width * 0.07,
                            backgroundColor: kWhiteColor,
                            child: Text(
                              friend.name?.substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: kGradColors[0],
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: size.width * 0.04),

                        // Friend info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.name ?? 'Unknown User',
                                style: TextStyle(
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GT-Walsheim-Pro',
                                  color: kBlackColor,
                                ),
                              ),
                              SizedBox(height: size.height * 0.005),
                              Text(
                                friend.email ?? 'No email',
                                style: TextStyle(
                                  fontSize: size.width * 0.035,
                                  color: kGreyColor,
                                  fontFamily: 'GT-Walsheim-Pro',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGradColors[0],
                        foregroundColor: kWhiteColor,
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isAlreadyFriend ? 'OK' : 'Great!',
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GT-Walsheim-Pro',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
