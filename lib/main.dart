import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food.dart';
import 'api_service.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
await FirebaseAuth.instance.signOut();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Nutrition Retriever',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 21, 83, 24)),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
      //home: const ImageClassifier(),
    );
  }
}

class AuthWrapper extends StatelessWidget{
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context){
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          User? user = snapshot.data;
          if (user == null){
            return const LoginScreen();
          }
          return const ImageClassifier();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim()
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ImageClassifier()));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Account not found';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email provided.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 3)),
      );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 3)),
      );
    }
  }

  Future<void> _signUp() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully'), duration: Duration(seconds: 3)),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email provided.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 3)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 3)),
      );
    }
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageClassifier extends StatefulWidget{
  const ImageClassifier({super.key});

  @override
  State<ImageClassifier> createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  File? image;
  List<String> _labels = [];
  String _classificationResult = 'No Image Classified';
  Interpreter? _interpreter;
  bool _isClassifying = false;
  bool _isLoadingNutrition = false;
  List<Food>? _nutritionInfo = [];
  String foodName = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    try{
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    }catch(e){
      print('Failed to load model: $e');
    }
  }

  Future<void> _loadLabels() async {
    final labelsText = await rootBundle.loadString('assets/labels.txt');
    setState(() {
      _labels = labelsText.split('\n').where((label) => label.isNotEmpty).toList();
    });
  }

  Future<void> _takeImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
    if(pickedFile != null){
      setState(() {
      image = File(pickedFile.path);
      });
      await _classifyImage();
    }
  }

  Future<void> _classifyImage() async {
    if (image == null || _interpreter == null) return;
    setState(() {
      _isClassifying = true;
    });

    try{

      final img.Image? originalImage = img.decodeImage(image!.readAsBytesSync());
      final img.Image resizedImage = img.copyResize(originalImage!, width: 224, height: 224);
      final Float32List inputBuffer = _imageToFloat32List(resizedImage);

      final inputTensor = List.generate(1,(i) => List.generate(224, (j) => List.generate(224, (k) => List.generate(3, (channel) => inputBuffer[(j * 224 + k) * 3 + channel]))));
      final output = List.generate(1, (index) => List.filled(36, 0.0));

      _interpreter!.run(inputTensor, output);

      final maxIndex = _findMaxIndex(output[0]);

      setState(() {
        _classificationResult = _labels[maxIndex];
        _isClassifying = false;
      });
      await _fetchNutritionInfo(_classificationResult);
    } catch(e){
      print('Error during classification: $e');
      setState(() {
        _classificationResult = 'Error during classification';
        _isClassifying = false;
      });
    }
  }

  Future<void> _fetchNutritionInfo(String foodName) async{
  
    try{
      final apiService = ApiService();
      final nutritionData = await apiService.fetchNutrition(foodName);

      if(nutritionData == null || nutritionData.isEmpty){
        print('No nutrition data found');
        setState(() {
          _isLoadingNutrition = false;
          _nutritionInfo = [];
        });
        return;
      }

      final List<Food> fetchedInfo = await ApiService().fetchNutrition(foodName);
      setState(() {
        _nutritionInfo = fetchedInfo;
        _isLoadingNutrition = false;
      });

      if(fetchedInfo.isNotEmpty){
        await _saveNutritionInfo(fetchedInfo[0]);
      }
    }catch(e){
      print('Error fetching nutrition info: $e');
      setState(() {
        _isLoadingNutrition = false;
        _nutritionInfo = [];
      });
    }
  }

  Future<void> _showNutritionHistory() async {
    final historyFoods = await _fetchNutritionHistory();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nutrition History'),
        content: historyFoods.isEmpty
          ? const Text('No nutrition history found')
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: historyFoods.length,
                itemBuilder: (context, index) {
                  final food = historyFoods[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      'Calories: ${food.calories} kcal\n Serving Size: ${food.servingSize} g\n Carbohydrates: ${food.carbohydrates} g\n Fat: ${food.fatTotal} g\n Protein: ${food.protein} g\n Time Added: ${food.timestamp}',
                    )
                  );
                },
              ),
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Float32List _imageToFloat32List(img.Image image) {
    final bytes = Float32List(1 * 224 * 224 * 3);
    var index = 0;
    
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        bytes[index++] = (pixel.r / 255.0 - 0.5) * 2.0;
        bytes[index++] = (pixel.g / 255.0 - 0.5) * 2.0;
        bytes[index++] = (pixel.b / 255.0 - 0.5) * 2.0;
      }
    }
    return bytes;
  }

  int _findMaxIndex(List<double> scores) {
    double max = scores[0];
    int maxIndex = 0;
    
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > max) {
        max = scores[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    try{
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out successfully')),);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while signing out: $e')),
      );
    }
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Nutrition Retriever'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _signOut(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showNutritionHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding for content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            const SizedBox(height: 20), // Space from the top
            Center(
              child: image == null 
                ? const Text('No image found') 
                : _isClassifying
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(16.0), // Space around the image
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0), // Rounded corners
                        child: AspectRatio(
                          aspectRatio: 1, // Makes it a square
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover, // Scale and crop to fill the square
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20), // Space between image and classification result
            Center(
              child: Text(
                _isClassifying 
                  ? 'Classifying...' 
                  : _classificationResult,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20), // Space for future nutrition info
            // Placeholder for API calls or nutrition information
            Expanded(
            child: _isLoadingNutrition
              ? const Center(child: CircularProgressIndicator())
              : _nutritionInfo != null
                ? _buildNutritionInfo()
                : Container(
                  alignment: Alignment.topCenter,
                  child: Text("Nutrition info will appear here", style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center, // Center the button horizontally
              child: FloatingActionButton(
                onPressed: _takeImageFromCamera,
                child: const Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(height: 20), // Space below the button
          ],
        ),
      ),
    );
  }
  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo() {
    if (_nutritionInfo == null || _nutritionInfo==[]) {
      return Center(
        child: Text(
          'No nutrition information found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _nutritionInfo!.length,
      itemBuilder: (context, index){
        final food = _nutritionInfo![index];
        return Card(
          margin: const EdgeInsets.all(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildNutritionRow('Serving Size', '${food.servingSize} g'),
                _buildNutritionRow('Calories', '${food.calories} kcal'),
                _buildNutritionRow('Total Fat', '${food.fatTotal} g'),
                _buildNutritionRow('Saturated Fat', '${food.fatSaturated} g'),
                _buildNutritionRow('Carbohydrates', '${food.carbohydrates} g'),
                _buildNutritionRow('Protein', '${food.protein} g'),
                _buildNutritionRow('Sodium', '${food.sodium} mg'),
                _buildNutritionRow('Fiber', '${food.fiber} g'),
                _buildNutritionRow('Sugar', '${food.sugar} g'),
                _buildNutritionRow('Potassium', '${food.potassium} mg'),
                _buildNutritionRow('Cholesterol', '${food.cholesterol} mg'),
              ],
            ),
          ),
        );
      }
    );
  }
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  Future<void> _saveNutritionInfo(Food food) async {
    try{
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newEntryRef = _databaseRef
        .child('users')
        .child(user.uid)
        .child('nutrition')
        .push();

      await newEntryRef.set({
        'name': food.name,
        'servingSize': food.servingSize,
        'calories': food.calories,
        'fatTotal': food.fatTotal,
        'fatSaturated': food.fatSaturated,
        'carbohydrates': food.carbohydrates,
        'protein': food.protein,
        'sodium': food.sodium,
        'fiber': food.fiber,
        'sugar': food.sugar,
        'potassium': food.potassium,
        'cholesterol': food.cholesterol,
        'timestamp': DateTime.now().microsecondsSinceEpoch ~/ 1000000,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nutrition info saved successfully')),
      );
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while saving nutrition info: $e')),
      );
    }
  }

  Future<List<Food>> _fetchNutritionHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await _databaseRef
          .child('users')
          .child(user.uid)
          .child('nutrition')
          .once();

      final DataSnapshot dataSnapshot = snapshot.snapshot;

      if (dataSnapshot.value == null) return [];

      final Map<dynamic, dynamic> entriesMap =
          dataSnapshot.value as Map<dynamic, dynamic>;

      return entriesMap.values.map<Food>((entry) {
        return Food(
          name: entry['name'] ?? 'Unknown',
          servingSize: (entry['servingSize'] ?? 0).toDouble(),
          calories: (entry['calories'] ?? 0).toDouble(),
          fatTotal: (entry['fatTotal'] ?? 0).toDouble(),
          fatSaturated: (entry['fatSaturated'] ?? 0).toDouble(),
          protein: (entry['protein'] ?? 0).toDouble(),
          sodium: (entry['sodium'] ?? 0).toInt(),
          potassium: (entry['potassium'] ?? 0).toInt(),
          cholesterol: (entry['cholesterol'] ?? 0).toInt(),
          carbohydrates: (entry['carbohydrates'] ?? 0).toDouble(),
          fiber: (entry['fiber'] ?? 0).toDouble(),
          sugar: (entry['sugar'] ?? 0).toDouble(),
          timestamp: DateTime.fromMicrosecondsSinceEpoch(entry['timestamp'] *1000000), 
        );
      }).toList(); // Convert the Iterable<Food> to List<Food>
    } catch (e) {
      print('Error fetching nutrition history: $e');
      return [];
    }
  }
}