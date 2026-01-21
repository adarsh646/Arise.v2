import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  CloudinaryUploadResult({required this.secureUrl, required this.publicId});
}

class CloudinaryService {
  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    this.folder,
  });

  final String cloudName;
  final String uploadPreset;
  final String? folder;

  static CloudinaryService fromEnvironment() {
    const cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
    const uploadPreset = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
    const folder = String.fromEnvironment('CLOUDINARY_UPLOAD_FOLDER');
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw StateError(
        'Cloudinary config missing. Set CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET.',
      );
    }
    return CloudinaryService(
      cloudName: cloudName,
      uploadPreset: uploadPreset,
      folder: folder.isEmpty ? null : folder,
    );
  }

  Future<CloudinaryUploadResult> uploadFile(
    File file, {
    String resourceType = 'image',
    String? folderOverride,
  }) async {
    final uri =
        Uri.https('api.cloudinary.com', '/v1_1/$cloudName/$resourceType/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;
    final folderToUse = folderOverride ?? folder;
    if (folderToUse != null && folderToUse.isNotEmpty) {
      request.fields['folder'] = folderToUse;
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          data['error']?['message']?.toString() ?? 'Cloudinary upload failed';
      throw Exception(message);
    }
    return CloudinaryUploadResult(
      secureUrl: data['secure_url']?.toString() ?? '',
      publicId: data['public_id']?.toString() ?? '',
    );
  }

  Future<CloudinaryUploadResult> uploadBytes(
    Uint8List bytes,
    String fileName, {
    String resourceType = 'image',
    String? folderOverride,
  }) async {
    final uri =
        Uri.https('api.cloudinary.com', '/v1_1/$cloudName/$resourceType/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;
    final folderToUse = folderOverride ?? folder;
    if (folderToUse != null && folderToUse.isNotEmpty) {
      request.fields['folder'] = folderToUse;
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          data['error']?['message']?.toString() ?? 'Cloudinary upload failed';
      throw Exception(message);
    }
    return CloudinaryUploadResult(
      secureUrl: data['secure_url']?.toString() ?? '',
      publicId: data['public_id']?.toString() ?? '',
    );
  }
}
