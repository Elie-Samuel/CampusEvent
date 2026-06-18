import 'dart:io';
import '../../repositories/auth_repository.dart';

class UploadProfileImageUseCase {
  final AuthRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<String?> call(File imageFile) async {
    return await repository.uploadProfileImage(imageFile);
  }
}