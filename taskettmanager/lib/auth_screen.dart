import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
                child : Text("TaskettManager",
                  style: TextStyle(fontSize: 32)),
                height: 200),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signInWithEmail(
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signUpWithEmail(
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () async {
                final user = await AuthService().signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign in with Google')),
                  );
                }
              },
              icon:  Image.asset('assets/google.png', height: 24.0),
              label: Text('Sign In with Google'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
