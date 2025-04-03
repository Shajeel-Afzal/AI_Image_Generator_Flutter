import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _apiKey = "";
  String _modelVersion = 'dall-e-3';
  String _errorMessage = '';
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a prompt";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _imageUrl = null;
    });
    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/images/generations"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'prompt': _promptController.text,
          'n': 1,
          'size': '1024x1024',
          'model': _modelVersion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(data.toString());
        setState(() {
          _imageUrl = data['data'][0]["url"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Error: ${_parseErrorMessage(response.body)}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Exception: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final parsed = json.decode(responseBody);
      return parsed['error']['message'] ?? "Unknown error";
    } catch (_) {
      return "Failed to parse error message";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 10),
                      const Text(
                        "DALL-E",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Image Generator",
                        style: TextStyle(
                          color: const Color(0xFF00F5FF).withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              "Transform ideas into art",
                              textStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: const Color(0xFF252A34),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AI Model",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _modelVersion,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF1A1A2E),
                                  labelText: "Select Model",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                dropdownColor: const Color(0xFF252A34),
                                items: [
                                  DropdownMenuItem(
                                    value: "dall-e-3",
                                    child: Text(
                                      "DALL-E 3",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "dall-e-2",
                                    child: Text(
                                      "DALL-E 2",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _modelVersion = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      // Prompt Input Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: const Color(0xFF252A34),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What would you like to create?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _promptController,
                                decoration: InputDecoration(
                                  hintText:
                                      'A futuristic city with flying cars and neon lights',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A2E),
                                  prefixIcon: const Icon(
                                    Icons.brush,
                                    color: Color(0xFF6C63FF),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: 3,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // TextField(
                      //   controller: _promptController,
                      //   decoration: const InputDecoration(
                      //     labelText: "Enter your prompt",
                      //     hintText: "A futuristic city with flying cars",
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   maxLines: 3,
                      // ),
                      // const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: _isLoading ? null : _generateImage,
                      //   child:
                      //       _isLoading
                      //           ? const CircularProgressIndicator()
                      //           : const Text("Generate Image"),
                      // ),
                      // if (_errorMessage.isNotEmpty)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 10.0),
                      //     child: Text(
                      //       _errorMessage,
                      //       style: const TextStyle(color: Colors.red),
                      //     ),
                      //   ),
                      // const SizedBox(height: 20),
                      // Expanded(
                      //   child:
                      //       _imageUrl != null
                      //           ? Image.network(
                      //             _imageUrl!,
                      //             loadingBuilder: (
                      //               context,
                      //               child,
                      //               loadingProgress,
                      //             ) {
                      //               if (loadingProgress == null) return child;
                      //               return Center(
                      //                 child: CircularProgressIndicator(
                      //                   value:
                      //                       loadingProgress
                      //                                   .expectedTotalBytes !=
                      //                               null
                      //                           ? loadingProgress
                      //                                   .cumulativeBytesLoaded /
                      //                               loadingProgress
                      //                                   .expectedTotalBytes!
                      //                           : null,
                      //                 ),
                      //               );
                      //             },
                      //           )
                      //           : Center(
                      //             child: Text(
                      //               "your generated image will appear here",
                      //             ),
                      //           ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
