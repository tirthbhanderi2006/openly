import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadImage(File imageFile, String folderName) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref('$folderName/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
