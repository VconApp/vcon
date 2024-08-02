//profile.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; 

import 'package:vcon_3rdparty_auth/widgets/profile_menu.dart';
import 'package:vcon_3rdparty_auth/screens/third_party.dart';
import 'package:vcon_3rdparty_auth/screens/collection_status.dart';
import 'package:vcon_3rdparty_auth/screens/notification_total.dart';
import 'package:vcon_3rdparty_auth/screens/notification.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _updateUnreadCount();
    NotificationTotal().totalUnreadNotifier.addListener(_updateUnreadCount);
  }

  @override
  void dispose() {
    NotificationTotal().totalUnreadNotifier.removeListener(_updateUnreadCount);
    super.dispose();
  }

  void _updateUnreadCount() {
    _fetchUnreadNotificationsCount();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupRefreshListener();
    });
  }

  void _setupRefreshListener() {
    // Refresh count when the screen gains focus
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        _fetchUnreadNotificationsCount();
      }
      return Future.value(null);
    });
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('IR')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) return;

      String userIRID = userSnapshot.docs.first.get('irID');

      QuerySnapshot myProductsUnread = await FirebaseFirestore.instance
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('irID', isEqualTo: userIRID)
          .where('type', isEqualTo: 'my_products')
          .get();

      // Fetch unread count for 'collect_products'
      QuerySnapshot collectProductsUnread = await FirebaseFirestore.instance
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('collectorIRID', isEqualTo: userIRID)
          .where('type', isEqualTo: 'collect_products')
          .get();

      setState(() {
        _totalUnreadCount = myProductsUnread.docs.length + collectProductsUnread.docs.length;
      });

      // Update the NotificationTotal
      NotificationTotal().totalUnreadCount = _totalUnreadCount;
    } catch (e) {
      print("Error fetching unread notifications count: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final user = snapshot.data;
            if (user != null) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            // Wrap your Row with Expanded
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(45),
                                //color: Colors.blue,
                                // image: const DecorationImage(
                                //   fit: BoxFit.cover,
                                //   image: NetworkImage(
                                //     'https://img.freepik.com/free-vector/hand-painted-watercolor-pastel-sky-background_23-2148902771.jpg',
                                //   ),
                                // ),
                              ),
                              child: const CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://static.vecteezy.com/system/resources/thumbnails/002/318/271/small_2x/user-profile-icon-free-vector.jpg',
                                ),
                                radius: 45,
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  16), // Space between profile icon and account details
                          Expanded(
                            // Wrap your Column with Expanded
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Account Name: ${user.displayName ?? 'No Name'}',
                                //   style: const TextStyle(
                                //       fontSize: 15,
                                //       fontWeight: FontWeight.bold),
                                // ),
                                const SizedBox(
                                    height:
                                        8), // Space between account name and ID
                                Text(
                                  'Account ID: ${user.uid}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ProfileMenu(
                    //   text: "Edit Profile",
                    //   icon: const Icon(Icons.account_circle),
                    //   press: () {},
                    // ),
                    ProfileMenu(
                      text: "Third Party Collection",
                      icon: const Icon(Icons.collections),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ThirdPartyDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileMenu(
                      text: "Collection Status",
                      icon: const Icon(Icons.check),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CollectionStatusScreen(
                                isSelected: [true, false, false]),
                          ),
                        );
                      },
                    ),
                    ProfileMenu(
                      text: "Notifications",
                      icon: const Icon(Icons.notifications),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        ).then((_) => _updateUnreadCount());
                      },
                      badge: _totalUnreadCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$_totalUnreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No user logged in'));
            }
          }
        },
      ),
    );
  }
}
