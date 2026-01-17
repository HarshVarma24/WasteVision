import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_services.dart';
import '../services/news_service.dart';
import '../services/prediction_services.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  const HomeScreen({Key? key, required this.name}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;

  File? _image; // Store the selected image file
  bool _isPredicting = false;
  double _confidence = 0.0;
  String _prediction = "";

  List<Map<String, String>> _news = [];
  bool _isLoadingNews = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    File imageFile = File(picked.path);

    setState(() {
      _image = imageFile;
      _isPredicting = true;
      _confidence = 0.0;
      _prediction = "";
    });

    try {
      final result = await PredictionServices.uploadImage(imageFile);

      setState(() {
        _confidence = result['confidence'];
        _prediction = result['waste_type'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Prediction failed: $e")));
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (picked == null) return;

    File imageFile = File(picked.path);

    setState(() {
      _image = imageFile;
      _isPredicting = true;
      _confidence = 0.0;
      _prediction = "";
    });

    try {
      final result = await PredictionServices.uploadImage(imageFile);

      setState(() {
        _confidence = result['confidence'];
        _prediction = result['waste_type'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Prediction failed: $e")));
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }

  Future<void> _loadNews() async {
    try {
      final result = await NewsService.getEnvironmentalNews();
      setState(() {
        _news = result;
        _isLoadingNews = false;
      });
    } catch (e) {
      setState(() => _isLoadingNews = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open link")));
    }
  }

  void _logout() async {
    await ApiServices.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: Text("Welcome, ${widget.name}!"),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- HEADER --------------------
            Center(
              child: Column(
                children: [
                  const Text(
                    "WasteVision",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                  Text(
                    "Smart Waste Classification with AI",
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // -------------------- NEWS TITLE --------------------
            Text(
              "Environmental News",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // -------------------- NEWS SLIDER --------------------
            _isLoadingNews
                ? const Center(child: CircularProgressIndicator())
                : _news.isEmpty
                ? const Text("No news found")
                : CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: _news.map((article) {
                      return GestureDetector(
                        onTap: () {
                          final url = article['url'];
                          if (url != null) {
                            _openUrl(url);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title'] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article['description'] ?? "",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 25),

            // -------------------- CAMERA SECTION --------------------
            Text(
              "Classify Your Waste",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                //camera button
                Expanded(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.camera_alt, size: 50, color: Colors.white),
                          SizedBox(height: 10),
                          Text(
                            "Camera",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  //file picker button
                  child: GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.upload_file,
                            size: 50,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Upload",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.file(_image!, height: 200),
              ),

            if (_isPredicting)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
            if (!_isPredicting && _prediction.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? Colors.grey[800]
                        : const Color.fromARGB(255, 111, 215, 115),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        " Prediction: $_prediction ",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        " Confidence: ${_confidence.toStringAsFixed(2)}% ",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
