import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
  StatusProvider() {
    // Add a listener when the provider is initialized
    _addStatusListener();
  }
  void _addStatusListener() {
    final databaseRef = FirebaseDatabase.instance.ref();
    databaseRef.child('status').onValue.listen((event) {
      if (event.snapshot.exists) {
        _status = event.snapshot.value as bool;
        notifyListeners(); // Notify listeners about the change
      }
    });
  }
  // Function to fetch status from Firebase
  Future<void> fetchStatusFromFirebase() async{
    final databaseRef = FirebaseDatabase.instance.ref();
    final snapshot = await databaseRef.child('status').get();
    if(snapshot.exists){
      _status = snapshot.value as bool;
      notifyListeners();
    }
  }

  void toggleStatus() async{
    final databaseRef = FirebaseDatabase.instance.ref();
    _status = !_status;
    notifyListeners();
    //update the status in firebase:
    await databaseRef.child('status').set(_status);
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

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final DatabaseReference _database = FirebaseDatabase.instance.ref();
  @override
  void initState(){
    super.initState();
    // Fetch the initial status from Firebase:
    Provider.of<StatusProvider>(context, listen: false)
        .fetchStatusFromFirebase();
  }

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
              onPressed: () async{
                //toggle button
                statusProvider.toggleStatus();

              }, // Correct usage of toggleStatus
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
                color: statusProvider.status ? Colors.green : Colors.blueGrey,
                fontSize: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
