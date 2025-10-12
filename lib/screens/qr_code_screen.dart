import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/screens/qr_scanner_screen.dart';
import 'package:flutter/services.dart';
import 'package:splitemate/service/api_service.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: kStockColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: kGreyColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: kBlackColor),
              title: Text(
                'Regenerate Invite Token',
                style: TextStyle(
                  color: kBlackColor,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _regenerateInviteToken(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: kBlackColor),
              title: Text(
                'Copy Invite Token',
                style: TextStyle(
                  color: kBlackColor,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _copyInviteToken(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _regenerateInviteToken(BuildContext context) async {
    if (_isRegenerating) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _isRegenerating = true;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.patch('/user/regenerate/invite-token');

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data['invite_token'];

        if (newToken != null && newToken.isNotEmpty) {
          userProvider.updateInviteToken(newToken);
          await userProvider.saveUserData();
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Invite token regenerated successfully!'),
                backgroundColor: kGreenColor,
              ),
            );
          }
        } else {
          throw Exception('Invalid token received');
        }
      } else {
        throw Exception('Failed to regenerate token');
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to regenerate token: ${e.toString()}'),
            backgroundColor: kRedColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
      }
    }
  }

  void _copyInviteToken(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user.inviteToken;

    if (token.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: token));
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Invite token copied to clipboard!'),
            backgroundColor: kGreenColor,
          ),
        );
      }
    } else {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No invite token available'),
            backgroundColor: kRedColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kBlackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: kBlackColor),
            onPressed: () {
              // TODO: Implement download functionality
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download functionality coming soon!'),
                    backgroundColor: kGreenColor,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: kBlackColor),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(size.width * 0.06),
                child: Column(
                  children: [
                    // Main Content Card
                    Container(
                      padding: EdgeInsets.all(size.width * 0.06),
                      decoration: BoxDecoration(
                        color: kStockColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kBlackColor.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // User Profile Section
                          Row(
                            children: [
                              Container(
                                width: size.width * 0.15,
                                height: size.width * 0.15,
                                child: FractionallySizedBox(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: kGradColors,
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                      ),
                                    ),
                                    child: const FractionallySizedBox(
                                      widthFactor: 0.92,
                                      heightFactor: 0.92,
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/lion.jpg'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        color: kBlackColor,
                                        fontSize: size.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GT-Walsheim-Pro',
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: kGreyColor,
                                        fontSize: size.width * 0.035,
                                        fontFamily: 'GT-Walsheim-Pro',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.04),

                          // QR Code Section
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final currentUser = userProvider.user;
                              return AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.04),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: kYellowGradColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(size.width * 0.03),
                                        decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: QrImageView(
                                          data:
                                              currentUser.inviteToken.isNotEmpty
                                                  ? currentUser.inviteToken
                                                  : 'default_token',
                                          version: QrVersions.auto,
                                          size: size.width * 0.4,
                                          backgroundColor: kWhiteColor,
                                          foregroundColor: kBlackColor,
                                          embeddedImage: const AssetImage(
                                              'assets/images/coin.png'),
                                          embeddedImageStyle:
                                              QrEmbeddedImageStyle(
                                            size: const Size(30, 30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          SizedBox(height: size.height * 0.03),

                          // Scan to add friend text
                          Text(
                            'Scan to add friend with Splitemate',
                            style: TextStyle(
                              color: kBlackColor,
                              fontSize: size.width * 0.035,
                              fontFamily: 'GT-Walsheim-Pro',
                            ),
                          ),

                          SizedBox(height: size.height * 0.04),

                          // App and Token Details Section
                          Container(
                            padding: EdgeInsets.all(size.width * 0.04),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: kGreyColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                // App Info
                                Row(
                                  children: [
                                    Container(
                                      width: size.width * 0.08,
                                      height: size.width * 0.08,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: kGradColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet,
                                        color: kWhiteColor,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Splitemate',
                                            style: TextStyle(
                                              color: kBlackColor,
                                              fontSize: size.width * 0.035,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'GT-Walsheim-Pro',
                                            ),
                                          ),
                                          Text(
                                            'Expense Tracker',
                                            style: TextStyle(
                                              color: kGreyColor,
                                              fontSize: size.width * 0.03,
                                              fontFamily: 'GT-Walsheim-Pro',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: kGreyColor,
                                      size: 16,
                                    ),
                                  ],
                                ),

                                SizedBox(height: size.height * 0.02),

                                // Token Info
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, child) {
                                    final currentUser = userProvider.user;
                                    return Row(
                                      children: [
                                        Text(
                                          'Invite Token:',
                                          style: TextStyle(
                                            color: kGreyColor,
                                            fontSize: size.width * 0.03,
                                            fontFamily: 'GT-Walsheim-Pro',
                                          ),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          child: FittedBox(
                                            alignment: Alignment.centerLeft,
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              currentUser.inviteToken.isNotEmpty
                                                  ? currentUser.inviteToken
                                                  : 'No token available',
                                              style: TextStyle(
                                                color: kBlackColor,
                                                fontSize: size.width * 0.03,
                                                fontFamily: 'GT-Walsheim-Pro',
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.copy,
                                              color: kBlackColor, size: 16),
                                          onPressed: () =>
                                              _copyInviteToken(context),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.03),

                          // Want to join prompt
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement switch QR functionality
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Switch QR functionality coming soon!'),
                                    backgroundColor: kGreenColor,
                                  ),
                                );
                              }
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Want to join Splitemate? ',
                                    style: TextStyle(
                                      color: kBlackColor,
                                      fontSize: size.width * 0.03,
                                      fontFamily: 'GT-Walsheim-Pro',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Switch QR',
                                    style: TextStyle(
                                      color: kGreenColor,
                                      fontSize: size.width * 0.03,
                                      fontFamily: 'GT-Walsheim-Pro',
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom section with buttons and footer
            Container(
              padding: EdgeInsets.all(size.width * 0.06),
              child: Column(
                children: [
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: size.height * 0.055,
                          decoration: BoxDecoration(
                            color: kStockColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: kGreyColor.withValues(alpha: 0.3)),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const QRScannerScreen(),
                                ),
                              );
                            },
                            icon:
                                Icon(Icons.qr_code_scanner, color: kBlackColor),
                            label: Text(
                              'Open Scanner',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: size.width * 0.032,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Expanded(
                        child: Container(
                          height: size.height * 0.055,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: kGradColors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              // TODO: Implement share functionality
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Share functionality coming soon!'),
                                    backgroundColor: kGreenColor,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.share, color: kWhiteColor),
                            label: Text(
                              'Share QR',
                              style: TextStyle(
                                color: kWhiteColor,
                                fontSize: size.width * 0.032,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
