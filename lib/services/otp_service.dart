import 'dart:convert';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:travel_crew/main.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

class SendGridEmailService {
  static Future<bool> inviteUsersViaEmail({
    required String tripTitle,
    required List<String> emails,
  }) async {
    try {
      if (emails.isEmpty) {
        showCustomSnackBar(content: 'Please add at least one email');
        return false;
      }
      String sendGridApiKey = dotenv.env['EMAIL_KEY'] ?? '';
      String fromEmail = dotenv.env['Email'] ?? '';

      final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

      final body = {
        'personalizations': [
          {
            'to': emails.map((email) => {'email': email}).toList(),
            'subject': 'Invitation to join a Trip',
          },
        ],
        'from': {'email': fromEmail},
        'content': [
          {
            'type': 'text/plain',
            'value':
                'Trip: $tripTitle\n You have been invited to join a trip. Please open the app to accept the invitation.',
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 202) {
        print('✅ Email sent successfully!');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {}
    return false;
  }

  static Future<bool> sendEmailWithSendGrid({
    required String toEmail,
    required String subject,
    required String message,
  }) async {
    try {
      String sendGridApiKey = dotenv.env['EMAIL_KEY'] ?? '';
      String fromEmail = dotenv.env['Email'] ?? '';

      final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

      final body = {
        'personalizations': [
          {
            'to': [
              {'email': toEmail},
            ],
            'subject': subject,
          },
        ],
        'from': {'email': fromEmail},
        'content': [
          {'type': 'text/plain', 'value': message},
        ],
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 202) {
        print('✅ Email sent successfully!');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {}
    return false;
  }

  static Future<bool> addOtp({
    required String email,
    required String otp,
    int expiresInSeconds = 300,
  }) async {
    try {
      await firestore.collection(kOtpCollection).doc(email).set({
        'email': email,
        'otp': otp,
        'expire_time': DateTime.now().add(Duration(minutes: expiresInSeconds)),
      });
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      return await firestore.collection(kOtpCollection).doc(email).get().then((
        value,
      ) async {
        if (value.exists) {
          if (value.data()!['expire_time'].toDate().isBefore(DateTime.now())) {
            showCustomSnackBar(content: 'OTP expired');
            return false;
          }
          await firestore.collection(kOtpCollection).doc(value.id).delete();
          showCustomSnackBar(
            contentType: ContentType.success,
            title: 'Success',
            content: 'OTP verified successfully',
          );
          return true;
        } else {
          showCustomSnackBar(content: 'Invalid OTP');
          return false;
        }
      });
    } catch (e) {
      print(e);
    }
    return false;
  }

  static String generateOtp({int length = 5}) {
    String otp = '';
    for (int i = 0; i < length; i++) {
      otp += (Random().nextInt(10)).toString();
    }
    return otp;
  }
}
