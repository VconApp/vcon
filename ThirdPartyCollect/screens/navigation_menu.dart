import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import 'package:vcon_3rdparty_auth/screens/profile.dart';
import 'package:vcon_3rdparty_auth/auth_controller.dart';

class NavigationMenuScreen extends StatelessWidget {
  const NavigationMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final controller = Get.put(NavigationController(authController.authorizerIRID.value));

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 80,
        elevation: 0,
        selectedIndex: controller.selectedIndex.value,
         onDestinationSelected: (index) =>
            controller.selectedIndex.value = index,
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
          NavigationDestination(icon: Icon(Iconsax.shop), label: 'Shop'),
          NavigationDestination(icon: Icon(Iconsax.heart), label: 'Wishlist'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs; // Reactive extension variable to track selected index
  final String userEmail;

  NavigationController(this.userEmail);

 List<Widget> get screens => [
    Container(color: Colors.green),
    Container(color: Colors.purple),
    Container(color: Colors.orange),
    //ProfileScreen(userEmail: userEmail),
    const ProfileScreen(),
  ];
}