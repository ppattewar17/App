import 'package:flutter/material.dart';
import '../screens/doctor_login.dart';
import '../screens/login_screen.dart';

class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select User Type')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60), // width, height
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("I’m a Patient"),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorLoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("I’m a Doctor"),
            ),
          ],
        ),
      ),
    );
  }
}
