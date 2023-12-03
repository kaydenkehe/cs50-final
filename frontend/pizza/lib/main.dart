// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as I;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as requests;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() async {
  await GetStorage.init();
  runApp(const App());
}

String endpoint = 'http://10.250.1.195:12999'; // Server endpoint
final storage = GetStorage();

// Colors
// https://dribbble.com/shots/10750209-Interior-Mobile-App
// Credit to: Anastasia Marinicheva
var textColor = const Color(0xFFFFF4E8);
var textColorDark = const Color(0xFFACCDDD);
var backgroundColor = const Color(0xFF325261);
var backgroundColorDark = const Color(0xFF234050);
var backgroundColorLight = const Color(0xFF607B89);
var activeColor = const Color(0xFFF5B688);
var activeColorDark = const Color(0xFFCF997B);
var activeColorLight = const Color(0xFFEBCFB0);

//! --- MATERIALAPP ---

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // Route user to login or home depending on whether they are logged in or not
  getInitialRoute() {
    if (storage.read('username') != null) {
      return '/home';
    }
    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'Comfortaa', scaffoldBackgroundColor: backgroundColor),
      initialRoute: getInitialRoute(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/login/create_account': (context) => const CreateAccountPage(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // I got this bit of code from here:
        // https://stackoverflow.com/questions/59143443/how-to-make-flutter-app-font-size-independent-from-device-settings
        // This makes the font size independent of the device settings
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

//! --- LOGIN PAGE ---

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  var passwordVisibleIcon =
      Icon(Icons.remove_red_eye_outlined, color: activeColor);

  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  loginSubmit() async {
    String username = usernameController.text;
    String password = passwordController.text;

    var postJSON = {
      'username': username,
      'password': password,
    };
    var response = await sendRequest('login', postJSON, context);
    if (response['message'] == 'failure') {
      alert('Incorrect username or password', context);
    } else if (response['message'] == 'success') {
      storage.write('username', username);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColorDark,
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 20,
                    top: MediaQuery.of(context).size.height / 10),
                // Title text
                child: Text('Seefood',
                    style: TextStyle(fontSize: 70.0, color: textColor)),
              ),
              // Rounded box that contains page content
              Expanded(
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 30.0, right: 30.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(50.0),
                          topLeft: Radius.circular(50.0),
                        )),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height / 40),
                          // 'Sign in' text at top of container
                          child: Text('Sign in',
                              style:
                                  TextStyle(fontSize: 30.0, color: textColor)),
                        ),
                      ),
                      // Username input field
                      TextField(
                        cursorColor: textColor,
                        controller: usernameController,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: activeColor),
                          isDense: true,
                          labelText: 'Username',
                          labelStyle: TextStyle(color: activeColor),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                width: 3.0,
                                style: BorderStyle.solid,
                                color: activeColor,
                              )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                width: 3.0,
                                style: BorderStyle.solid,
                                color: activeColor,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 35,
                      ),
                      // Password input text field
                      TextField(
                        cursorColor: textColor,
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: activeColor),
                            isDense: true,
                            labelText: 'Password',
                            labelStyle: TextStyle(color: activeColor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(
                                  width: 3.0,
                                  style: BorderStyle.solid,
                                  color: activeColor,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(
                                  width: 3.0,
                                  style: BorderStyle.solid,
                                  color: activeColor,
                                )),
                            suffixIcon: IconButton(
                              icon: passwordVisibleIcon,
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                  if (obscurePassword) {
                                    passwordVisibleIcon = Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: activeColor);
                                  } else {
                                    passwordVisibleIcon = Icon(
                                        Icons.remove_red_eye,
                                        color: activeColor);
                                  }
                                });
                              },
                            )),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 25,
                      ),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(12.0)),
                            backgroundColor:
                                MaterialStateProperty.all(activeColor),
                            side: MaterialStateProperty.all(
                                BorderSide(color: activeColor)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                side: BorderSide(color: activeColor),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                          child: Text('Sign In',
                              style: TextStyle(
                                color: backgroundColor,
                                fontSize: 20.0,
                              )),
                          onPressed: () => loginSubmit(),
                        ),
                      ),
                      const Spacer(),
                      // Sign up text button at bottom of page
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('New user?',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17.0,
                                )),
                            TextButton(
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: activeColor,
                                  fontSize: 17.0,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login/create_account',
                                    (Route<dynamic> route) => false);
                              },
                            )
                          ])
                    ])),
              ),
            ],
          ),
        ));
  }
}

//! --- ACCOUNT REGISTRATION ---

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool passwordObscure = true; // Whether password field is obscured
  bool confirmPasswordObscure =
      true; // Whether confirm password field is obscured
  var passwordVisibleIcon =
      Icon(Icons.remove_red_eye_outlined, color: activeColor);
  var confirmPasswordVisibleIcon =
      Icon(Icons.remove_red_eye_outlined, color: activeColor);

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // Create account
  createAccountSubmit() async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      if (passwordController.text == confirmPasswordController.text) {
        var queries = {
          'username': usernameController.text,
          'password': passwordController.text,
          'email': emailController.text
        };
        var response = await sendRequest('register', queries, context);

        if (response['msg'] == 'exist') {
          alert('Username already exists', context);
        } else if (response['msg'] == 'success') {
          storage.write('username', usernameController.text);
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        }
      } else {
        alert('Passwords do not match', context);
      }
    } else {
      alert('One or more fields are empty', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 30.0, bottom: 15.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                // 'Create Account' text at top of page
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 40),
                    child: Text('Create Account',
                        style: TextStyle(fontSize: 30.0, color: textColor)),
                  ),
                ),
                // Username input field
                TextField(
                  cursorColor: textColor,
                  controller: usernameController,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: activeColor),
                    isDense: true,
                    labelText: 'Username',
                    labelStyle: TextStyle(color: activeColor),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                          width: 3.0,
                          style: BorderStyle.solid,
                          color: activeColor,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                          width: 3.0,
                          style: BorderStyle.solid,
                          color: activeColor,
                        )),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 55,
                ),
                // Password and confirm password input fields
                Row(children: [
                  Expanded(
                    // Password input field
                    child: TextField(
                      cursorColor: textColor,
                      controller: passwordController,
                      obscureText: passwordObscure,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: activeColor),
                        isDense: true,
                        labelText: 'Password',
                        labelStyle: TextStyle(color: activeColor),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              width: 3.0,
                              style: BorderStyle.solid,
                              color: activeColor,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              width: 3.0,
                              style: BorderStyle.solid,
                              color: activeColor,
                            )),
                        suffixIcon: IconButton(
                          icon: passwordVisibleIcon,
                          onPressed: () {
                            setState(() {
                              passwordObscure = !passwordObscure;
                              if (passwordObscure) {
                                passwordVisibleIcon = Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: activeColor);
                              } else {
                                passwordVisibleIcon = Icon(Icons.remove_red_eye,
                                    color: activeColor);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 100),
                  // Confirm password input field
                  Expanded(
                    child: TextField(
                      cursorColor: textColor,
                      controller: confirmPasswordController,
                      obscureText: confirmPasswordObscure,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: activeColor),
                        isDense: true,
                        labelText: 'Confirm',
                        labelStyle: TextStyle(color: activeColor),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              width: 3.0,
                              style: BorderStyle.solid,
                              color: activeColor,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              width: 3.0,
                              style: BorderStyle.solid,
                              color: activeColor,
                            )),
                        suffixIcon: IconButton(
                          icon: confirmPasswordVisibleIcon,
                          onPressed: () {
                            setState(() {
                              confirmPasswordObscure = !confirmPasswordObscure;
                              if (confirmPasswordObscure) {
                                confirmPasswordVisibleIcon = Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: activeColor);
                              } else {
                                confirmPasswordVisibleIcon = Icon(
                                    Icons.remove_red_eye,
                                    color: activeColor);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 55,
                ),
                // Email input field
                TextField(
                  cursorColor: textColor,
                  controller: emailController,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: activeColor),
                    isDense: true,
                    labelText: 'Email',
                    labelStyle: TextStyle(color: activeColor),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                          width: 3.0,
                          style: BorderStyle.solid,
                          color: activeColor,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                          width: 3.0,
                          style: BorderStyle.solid,
                          color: activeColor,
                        )),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 40,
                ),
                const Spacer(),
                // Create account button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(12.0)),
                      backgroundColor: MaterialStateProperty.all(activeColor),
                      side: MaterialStateProperty.all(
                          BorderSide(color: activeColor)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          side: BorderSide(color: activeColor),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: Text('Create Account',
                        style: TextStyle(
                          color: backgroundColor,
                          fontSize: 20.0,
                        )),
                    onPressed: () => createAccountSubmit(),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 80),
                // Text button that takes you to sign in
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.0,
                          )),
                      TextButton(
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: activeColor,
                            fontSize: 14.0,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (Route<dynamic> route) => false);
                        },
                      )
                    ])
              ],
            )));
  }
}

//! --- HOME PAGE ---

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;

  @override
  void initState() {
    setupCamera();
    super.initState();
  }

  void setupCamera() async {
    cameras = await availableCameras();
    cameraController =
        CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
    await cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void submitPhoto() async {
    try {
      final XFile photoXFile = await cameraController.takePicture();
      final imageData =
          I.decodeImage(await photoXFile.readAsBytes())?.getBytes();
      var response =
          await sendRequest('predict', {'image': imageData}, context);
      if (response['prediction'] == 0) {
        alert('Not Pizza', context);
      } else if (response['prediction'] == 1) {
        alert('Pizza', context);
      }
    } catch (e) {
      alert("Error sending photo", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return const SizedBox();
    } else {
      return Scaffold(
          backgroundColor: backgroundColorDark,
          resizeToAvoidBottomInset: false,
          body: Center(
              child: Column(children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                  bottomLeft: Radius.circular(25.0),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CameraPreview(cameraController),
                ),
              ),
            )),
            Container(
                height: 60.0,
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 5.0, left: 20.0, right: 20.0, bottom: 5.0),
                decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25.0),
                      topLeft: Radius.circular(25.0),
                    )),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        launchUrlString('https://www.youtube.com/@kaydenkehe');
                      },
                      icon: Icon(Icons.smart_display_outlined,
                          size: 35, color: backgroundColorDark),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(12.0)),
                        backgroundColor:
                            MaterialStateProperty.all(backgroundColorDark),
                        side: MaterialStateProperty.all(
                            BorderSide(color: backgroundColorDark)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: BorderSide(color: backgroundColorDark),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      child: Row(children: [
                        Text('Take Photo',
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 15.0,
                            )),
                        const SizedBox(width: 5.0),
                        Icon(Icons.camera_alt_outlined,
                            size: 20, color: activeColor)
                      ]),
                      onPressed: () => submitPhoto(),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        storage.remove('username');
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', (Route<dynamic> route) => false);
                      },
                      icon: Icon(Icons.logout,
                          size: 35, color: backgroundColorDark),
                    ),
                  ],
                )),
          ])));
    }
  }
}

//! --- ALERT DIALOG WIDGET ---
// Used to let the user know something has gone wrong

alert(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          content:
              Text(message, style: TextStyle(color: textColor, fontSize: 17.0)),
          actions: [
            TextButton(
              child: Text('Okay',
                  style: TextStyle(color: activeColor, fontSize: 15.0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

//! --- SEND HTTP REQUEST ---

sendRequest(String path, var postJSON, BuildContext context) async {
  try {
    await requests
        .get(Uri.parse('$endpoint/test'))
        .timeout(const Duration(seconds: 15));
  } catch (e) {
    alert('The server is down', context);
    return 0;
  }

  try {
    String request = '$endpoint/$path';
    requests.Response response = await requests.post(Uri.parse(request),
        body: jsonEncode(postJSON),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json'
        });
    return json.decode(response.body);
  } catch (e) {
    alert('Something went wrong', context);
    return 0;
  }
}
