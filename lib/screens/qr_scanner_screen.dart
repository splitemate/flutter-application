import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/widgets/popup/friend_added_dialog.dart';
import 'package:splitemate/service/friend_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  bool isLoading = false;
  bool isFlashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addFriend(String token) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final friendResult = await FriendService().addFriend(token);

      // Vibrate on success
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 500);
      }

      if (mounted) {
        _showSuccessDialog(friendResult.user,
            isAlreadyFriend: friendResult.isAlreadyFriend);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(User friend, {required bool isAlreadyFriend}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FriendAddedDialog(
          friend: friend,
          isAlreadyFriend: isAlreadyFriend,
          onClose: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    simpleAlertBox(
      context,
      'Error',
      message,
      size: MediaQuery.of(context).size,
      buttonText: 'Try Again',
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          isScanning = true;
        });
      },
      secondButtonText: 'Try Again',
      onSecondButtonTap: () {
        Navigator.of(context).pop();
        setState(() {
          isScanning = true;
        });
      },
      secondButtonColors: [kRedColor, kRedColor],
      secondButtonTextColor: kWhiteColor,
    );
  }

  void _showManualInputDialog() {
    final TextEditingController tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Enter Friend Code',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
              fontFamily: 'GT-Walsheim-Pro',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the friend code manually if scanning is not working',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: kGreyColor,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'Enter friend code...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kGradColors[0]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kGradColors[0], width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: kGreyColor,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (tokenController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _addFriend(tokenController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGradColors[0],
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Friend',
                style: TextStyle(
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBlackColor,
      appBar: AppBar(
        backgroundColor: kBlackColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kWhiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scan QR Code',
          style: TextStyle(
            color: kWhiteColor,
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT-Walsheim-Pro',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: kWhiteColor,
            ),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!isScanning) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    isScanning = false;
                  });
                  _addFriend(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),

          Center(
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(
                  color: kWhiteColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * (size.width * 0.7 - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                kGradColors[0],
                                kGradColors[1],
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Corner decorations
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    left: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          topLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: size.height * 0.05,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: kBlackColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: kWhiteColor,
                        size: size.width * 0.06,
                      ),
                      SizedBox(height: size.height * 0.008),
                      Text(
                        'Position the QR code within the frame',
                        style: TextStyle(
                          color: kWhiteColor,
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GT-Walsheim-Pro',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.003),
                      Text(
                        'Scanning will happen automatically',
                        style: TextStyle(
                          color: kWhiteColor.withValues(alpha: 0.7),
                          fontSize: size.width * 0.03,
                          fontFamily: 'GT-Walsheim-Pro',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                // Manual input button
                Container(
                  width: size.width * 0.5,
                  child: ElevatedButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: Icon(Icons.edit,
                        color: kWhiteColor, size: size.width * 0.04),
                    label: Text(
                      'Enter Code Manually',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGradColors[0].withValues(alpha: 0.8),
                      foregroundColor: kWhiteColor,
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.012),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kWhiteColor),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'Adding friend...',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
