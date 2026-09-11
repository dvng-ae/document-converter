import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DocumentConverterApp());
}

// =====================================================
// MAIN APP
// =====================================================

class DocumentConverterApp extends StatelessWidget {
  const DocumentConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Document Converter',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFFF8FF),
      ),

      home: const HomePage(),
    );
  }
}

// =====================================================
// HOME PAGE
// =====================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ===================================================
  // PDF
  // ===================================================

  Future<void> pickPdf(BuildContext context) async {
    await pickFile(
      context: context,
      extensions: ['pdf'],
      conversionType: 'PDF → Text',
      outputExtension: 'txt',
      icon: Icons.picture_as_pdf,
      iconColor: Colors.red,
    );
  }

  // ===================================================
  // EXCEL
  // ===================================================

  Future<void> pickExcel(BuildContext context) async {
    await pickFile(
      context: context,
      extensions: ['xlsx', 'xls'],
      conversionType: 'Excel → PDF',
      outputExtension: 'pdf',
      icon: Icons.table_chart,
      iconColor: Colors.green,
    );
  }

  // ===================================================
  // WORD
  // ===================================================

  Future<void> pickWord(BuildContext context) async {
    await pickFile(
      context: context,
      extensions: ['docx', 'doc'],
      conversionType: 'Word → PDF',
      outputExtension: 'pdf',
      icon: Icons.description,
      iconColor: Colors.blue,
    );
  }

  // ===================================================
  // POWERPOINT
  // ===================================================

  Future<void> pickPpt(BuildContext context) async {
    await pickFile(
      context: context,
      extensions: ['pptx', 'ppt'],
      conversionType: 'PPT → PDF',
      outputExtension: 'pdf',
      icon: Icons.slideshow,
      iconColor: Colors.orange,
    );
  }

  // ===================================================
  // COMMON FILE PICKER
  // ===================================================

  Future<void> pickFile({
    required BuildContext context,
    required List<String> extensions,
    required String conversionType,
    required String outputExtension,
    required IconData icon,
    required Color iconColor,
  }) async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        withData: true,
      );

      if (result == null) {
        return;
      }

      final PlatformFile file = result.files.single;

      final Uint8List? bytes = file.bytes;

      if (bytes == null) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not read the selected file.',
            ),
          ),
        );

        return;
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversionPage(
            fileName: file.name,
            fileBytes: bytes,
            conversionType: conversionType,
            outputExtension: outputExtension,
            icon: icon,
            iconColor: iconColor,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select file: $e',
          ),
        ),
      );
    }
  }

  // ===================================================
  // HOME UI
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Conversion',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // =========================================
            // BLUE HEADER
            // =========================================

            Container(
              width: double.infinity,
              height: 200,

              decoration: BoxDecoration(
                color: Colors.blue[800],
                border: Border.all(
                  color: Colors.blue[900]!,
                  width: 2,
                ),
              ),

              child: const Column(
                children: [
                  SizedBox(height: 20),

                  Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 55,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Convert Your Documents',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Fast • Easy • Offline',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // =========================================
            // PDF → TEXT
            // =========================================

            ConversionCard(
              title: 'PDF → Text',
              description: 'Extract text from PDF files',
              leftIcon: Icons.picture_as_pdf,
              rightIcon: Icons.text_snippet,
              leftColor: Colors.red,
              rightColor: Colors.blue,
              onTap: () {
                pickPdf(context);
              },
            ),

            // =========================================
            // EXCEL → PDF
            // =========================================

            ConversionCard(
              title: 'Excel → PDF',
              description: 'Convert Excel files to PDF',
              leftIcon: Icons.table_chart,
              rightIcon: Icons.picture_as_pdf,
              leftColor: Colors.green,
              rightColor: Colors.red,
              onTap: () {
                pickExcel(context);
              },
            ),

            // =========================================
            // WORD → PDF
            // =========================================

            ConversionCard(
              title: 'Word → PDF',
              description: 'Convert Word files to PDF',
              leftIcon: Icons.description,
              rightIcon: Icons.picture_as_pdf,
              leftColor: Colors.blue,
              rightColor: Colors.red,
              onTap: () {
                pickWord(context);
              },
            ),

            // =========================================
            // PPT → PDF
            // =========================================

            ConversionCard(
              title: 'PPT → PDF',
              description: 'Convert PowerPoint files to PDF',
              leftIcon: Icons.slideshow,
              rightIcon: Icons.picture_as_pdf,
              leftColor: Colors.orange,
              rightColor: Colors.red,
              onTap: () {
                pickPpt(context);
              },
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// CONVERSION CARD
// =====================================================

class ConversionCard extends StatelessWidget {
  final String title;
  final String description;

  final IconData leftIcon;
  final IconData rightIcon;

  final Color leftColor;
  final Color rightColor;

  final VoidCallback onTap;

  const ConversionCard({
    super.key,
    required this.title,
    required this.description,
    required this.leftIcon,
    required this.rightIcon,
    required this.leftColor,
    required this.rightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,

        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Icon(
                      leftIcon,
                      color: leftColor,
                      size: 55,
                    ),

                    const SizedBox(width: 15),

                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.blueGrey,
                      size: 30,
                    ),

                    const SizedBox(width: 15),

                    Icon(
                      rightIcon,
                      color: rightColor,
                      size: 55,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,

                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CONVERSION PAGE
// =====================================================

class ConversionPage extends StatefulWidget {
  final String fileName;
  final Uint8List fileBytes;

  final String conversionType;
  final String outputExtension;

  final IconData icon;
  final Color iconColor;

  const ConversionPage({
    super.key,
    required this.fileName,
    required this.fileBytes,
    required this.conversionType,
    required this.outputExtension,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<ConversionPage> createState() =>
      _ConversionPageState();
}

// =====================================================
// CONVERSION PAGE STATE
// =====================================================

class _ConversionPageState
    extends State<ConversionPage> {

  bool converting = false;
  bool converted = false;

  Uint8List? convertedFileBytes;

  // ===================================================
  // PYTHON SERVER
  // ===================================================

  static const String serverUrl =
      'https://document-converter-api-v9fe.onrender.com';

  // ===================================================
  // SELECT ENDPOINT
  // ===================================================

  String get endpoint {
    switch (widget.conversionType) {
      case 'PDF → Text':
        return '$serverUrl/pdf-to-text';

      case 'Excel → PDF':
        return '$serverUrl/excel-to-pdf';

      case 'Word → PDF':
        return '$serverUrl/word-to-pdf';

      case 'PPT → PDF':
        return '$serverUrl/ppt-to-pdf';

      default:
        return '';
    }
  }

  // ===================================================
  // START CONVERSION
  // ===================================================

  Future<void> startConversion() async {
    if (endpoint.isEmpty) {
      showError('Unknown conversion type.');
      return;
    }

    setState(() {
      converting = true;
      converted = false;
      convertedFileBytes = null;
    });

    try {
      print('================================');
      print('DOCUMENT CONVERSION');
      print('Type: ${widget.conversionType}');
      print('File: ${widget.fileName}');
      print(
        'Size: ${widget.fileBytes.length} bytes',
      );
      print('Server: $endpoint');
      print('================================');

      // =============================================
      // CREATE MULTIPART REQUEST
      // =============================================

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      // =============================================
      // ADD FILE
      // =============================================

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          widget.fileBytes,
          filename: widget.fileName,
        ),
      );

      // =============================================
      // SEND TO PYTHON
      // =============================================

      final response = await request.send();

      print(
        'Python response status: '
            '${response.statusCode}',
      );

      // =============================================
      // SUCCESS
      // =============================================

      if (response.statusCode == 200) {
        final Uint8List resultBytes =
        await response.stream.toBytes();

        print('Conversion successful!');

        print(
          'Received ${resultBytes.length} bytes',
        );

        if (!mounted) return;

        setState(() {
          convertedFileBytes = resultBytes;
          converting = false;
          converted = true;
        });
      }

      // =============================================
      // SERVER ERROR
      // =============================================

      else {
        final String error =
        await response.stream.bytesToString();

        throw Exception(
          'Server returned ${response.statusCode}: '
              '$error',
        );
      }
    } catch (e) {
      print('CONVERSION ERROR: $e');

      if (!mounted) return;

      setState(() {
        converting = false;
        converted = false;
      });

      showError(
        'Conversion failed:\n$e',
      );
    }
  }

  // ===================================================
  // SHOW ERROR
  // ===================================================

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  // ===================================================
  // SAVE FILE
  // ===================================================

  Future<void> saveFile() async {
    if (convertedFileBytes == null) {
      showError('No converted file available.');
      return;
    }

    // =============================================
    // GET ORIGINAL NAME
    // =============================================

    String originalName = widget.fileName;

    final int dotPosition =
    originalName.lastIndexOf('.');

    if (dotPosition != -1) {
      originalName =
          originalName.substring(
            0,
            dotPosition,
          );
    }

    // =============================================
    // DEFAULT OUTPUT NAME
    // =============================================

    final String suggestedName =
        '$originalName.${widget.outputExtension}';

    try {
      // ===========================================
      // ANDROID SAVE DIALOG
      // ===========================================

      final String? savePath =
      await FilePicker.platform.saveFile(
        dialogTitle: 'Save converted file',

        fileName: suggestedName,

        type: FileType.custom,

        allowedExtensions: [
          widget.outputExtension,
        ],

        // IMPORTANT FOR ANDROID
        bytes: convertedFileBytes!,
      );

      // ===========================================
      // CANCELLED
      // ===========================================

      if (savePath == null) {
        return;
      }

      print(
        'File saved: $savePath',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'File saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('SAVE ERROR: $e');

      if (!mounted) return;

      showError(
        'Could not save file:\n$e',
      );
    }
  }

  // ===================================================
  // BUILD CONVERSION PAGE
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ===============================================
      // APP BAR
      // ===============================================

      appBar: AppBar(
        title: Text(
          widget.conversionType,

          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        centerTitle: true,

        backgroundColor: Colors.blue[800],

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ===============================================
      // BODY
      // ===============================================

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 30),

            // =========================================
            // FILE ICON
            // =========================================

            Icon(
              widget.icon,
              color: widget.iconColor,
              size: 90,
            ),

            const SizedBox(height: 20),

            // =========================================
            // SELECTED FILE
            // =========================================

            const Text(
              'Selected File',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.grey[100],

                borderRadius:
                BorderRadius.circular(10),

                border: Border.all(
                  color: Colors.grey,
                ),
              ),

              child: Text(
                widget.fileName,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 35),

            // =========================================
            // CONVERSION ANIMATION
            // =========================================

            if (converting) ...[
              const SizedBox(height: 10),

              const SizedBox(
                width: 70,
                height: 70,

                child: CircularProgressIndicator(
                  strokeWidth: 5,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Converting...',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.conversionType,

                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please wait...',
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ]

            // =========================================
            // CONVERSION COMPLETE
            // =========================================

            else if (converted) ...[
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 75,
              ),

              const SizedBox(height: 15),

              const Text(
                'Conversion Complete!',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your ${widget.outputExtension.toUpperCase()} '
                    'file is ready.',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 25),

              // =======================================
              // SAVE BUTTON
              // =======================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: saveFile,

                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),

                  label: const Text(
                    'Save File',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue[800],

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ]

            // =========================================
            // CONVERT BUTTON
            // =========================================

            else ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: startConversion,

                    icon: const Icon(
                      Icons.sync,
                      color: Colors.white,
                    ),

                    label: Text(
                      'Convert to '
                          '${widget.outputExtension.toUpperCase()}',

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.blue[800],

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}