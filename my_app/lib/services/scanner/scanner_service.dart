import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Captures an image from the camera and extracts mathematical expressions.
  /// Returns a JSON string ready for AI model processing.
  Future<String?> scanMathProblem() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract all text blocks and join them
      String extractedText = recognizedText.text;

      // Prepare the payload
      final payload = {
        'timestamp': DateTime.now().toIso8601String(),
        'raw_text': extractedText,
        'blocks': recognizedText.blocks.map((block) => {
          'text': block.text,
          'bounding_box': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'right': block.boundingBox.right,
            'bottom': block.boundingBox.bottom,
          },
        }).toList(),
      };

      return jsonEncode(payload);
    } catch (e) {
      print('Error during scanning: $e');
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
