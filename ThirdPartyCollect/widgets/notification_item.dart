import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String body;
  final String timeString;
  final String dateString;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.body,
    required this.timeString,
    required this.dateString,
    required this.isRead,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isRead ? Colors.white : Colors.grey[200],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isRead ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: isRead ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 12,
                    color: isRead ? Colors.grey : Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 12,
                    color: isRead ? Colors.grey : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}