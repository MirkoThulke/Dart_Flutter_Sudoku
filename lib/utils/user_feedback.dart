import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackHelper {
  static Future<void> sendFeedback(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com', // <-- replace with your email
      query: 'subject=App Feedback&body=Describe your feedback here...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Could not open the email app.'),
        ),
      );
    }
  }
}
