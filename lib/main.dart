import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => StatusProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class StatusProvider extends ChangeNotifier {
  bool _status = true;
  bool get status => _status;

  void toggleStatus() {
    _status = !_status;
    notifyListeners();
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  // Check if this is the first time the app is being opened
  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
  }

  // Set that the user has completed the onboarding
  Future<void> _setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);

    if (!_isFirstTime) {
      return HomeScreen(); // Navigate to your home screen if not first time
    }

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to MyApp",
          body: "This is the first page of the introduction.",
          image: Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/onboard/1.png"),
                      fit: BoxFit.fill)),
            ),
          ),
        ),
        PageViewModel(
          title: "Second Page",
          body: "This is the second page of the introduction.",
          image: Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/onboard/2.jpg"),
                      fit: BoxFit.fill)),
            ),
          ),
        ),
        PageViewModel(
          title: "Let's Get Started",
          body: "Ready to start using the app?",
          image: Center(child: Icon(Icons.check, size: 100.0)),
          footer: ElevatedButton(
            onPressed: () {
              _setOnboardingCompleted(); // Mark onboarding as completed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("Start Now"),
          ),
        ),
      ],
      onDone: () {
        _setOnboardingCompleted(); // Mark onboarding as completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      },
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Correct usage of Provider to access StatusProvider
    final statusProvider = Provider.of<StatusProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Home Screen"), centerTitle: true),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: statusProvider.toggleStatus, // Correct usage of toggleStatus
              child: Text(
                "Click Me",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Text(
              statusProvider.status ? "Status: True" : "Status: False", // Correctly accessing the status
              style: TextStyle(
                color: statusProvider.status ? Colors.green : Colors.red,
                fontSize: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
