//submit_success.dart
import 'package:flutter/material.dart';

class SubmitSuccessScreen extends StatelessWidget {
  const SubmitSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Submitted successfully!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please update your collector IR ID within 24 hours if you want to change another collector.',
                    style: TextStyle(
                      fontSize: 14
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}