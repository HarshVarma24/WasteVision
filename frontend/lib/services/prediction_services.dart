import 'dart:io'; // For File
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON encoding/decoding

class PredictionServices {
  static const String baseUrl = 'http://192.168.232.223:8000';
  
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async{
    try{
      final request = http.MultipartRequest(  // Create a multipart request, multipart means it can handle file uploads
        'POST', Uri.parse('$baseUrl/predict'),
      ); 
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path)  // Attach the image file to the request
      );
      final response = await request.send();  // Send the request
      
      if(response.statusCode == 200){
        final responseData = await response.stream.bytesToString(); // Read the response data as a string
        return jsonDecode(responseData);  // Decode and return the JSON response
      }
      else{
        throw Exception('Failed to upload image');
      }
    }
    catch(e){
      throw Exception('Error uploading image: $e');
    }
  }
}
