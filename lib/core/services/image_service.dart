import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../config.dart'; 


class ImageService {
  final ImagePicker _picker = ImagePicker();

  
  Future<Uint8List?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, 
      );
      return pickedFile != null ? await pickedFile.readAsBytes() : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String folderPath, 
  }) async {
    try {
      
      var request = http.MultipartRequest('POST', Uri.parse(Config.imagekitUrl));

      
      request.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('${Config.privateKey}:'))}';

      
      request.fields['fileName'] = fileName;
      request.fields['publicKey'] = Config.publicKey;
      
      request.fields['folder'] = folderPath; 

      
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: fileName));

      
      var response = await request.send();

      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['url']; 
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
          print('Response: ${await response.stream.bytesToString()}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Image upload error: $e');
      }
      return null;
    }
  }
}