import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_bootstrap/create_login.dart';
import 'package:notes_bootstrap/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var emailError = "";
  var passwordError = "";

  void signIn(String email, String password) async {
    bool success = false;
    try{
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password);
      //If the code reaches here, then the account was successfully created. If there were
      //any errors, it would be caught and code would be run in the catch below this comment.
      goToHome();
    } on FirebaseAuthException catch (e){
      //Reset fields and recheck every error
      setState(() {
        passwordError = "";
        emailError = "";
      });
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        setState(() {
          emailError = 'No user found for that email.';
        });
      }
      if (e.code == 'wrong-password') {
        setState(() {
          passwordError = 'Wrong password provided for that user.';
        });
      }
      if(email.isEmpty){
        setState(() {
          emailError = "Please type an e-mail";
        });
      }
      if(password.isEmpty){
        setState(() {
          passwordError = "Please type a password";
        });
      }
    } catch (e) {
      print(e);
    }
  }
  
  void goToHome(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text("Welcome to Notes!", style: TextStyle(fontSize: 30),)),
          const SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "E-mail",
                helperText: emailError,
                helperStyle: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                helperText: passwordError,
                helperStyle: const TextStyle(color: Colors.red),
              ),
              obscureText: true,
            ),
          ),
          ElevatedButton(onPressed: () => signIn(emailController.text, passwordController.text), child: const Text("Login")),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateLoginPage())), child: const Text("Create an account")),
        ],
      ),
    );
  }
}
