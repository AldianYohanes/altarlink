// altarlink4/lib/services/post_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:altarlink4/models/post_model.dart';
import 'package:altarlink4/models/user_model.dart'; // Pastikan UserModel diimpor
import 'package:altarlink4/services/auth/auth_service.dart'; // Pastikan AuthService diimpor

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService =
      AuthService(); // Gunakan AuthService yang sudah ada

  // Helper untuk mengunggah gambar ke Firebase Storage
  Future<String?> uploadImage(XFile imageFile) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in.");
    }

    File file = File(imageFile.path);
    // Path: posts/{user_uid}/{timestamp}.jpg
    String fileName =
        'posts/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded to Storage: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Firebase Storage Error: ${e.code} - ${e.message}");
      throw Exception("Firebase Storage Error: ${e.code} - ${e.message}");
    } catch (e) {
      print("General Upload Image Error: $e");
      throw Exception("Gagal mengunggah gambar: ${e.toString()}");
    }
  }

  // Mengambil stream semua postingan (untuk Home Page / Admin)
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // --- BARIS BARU: Mengambil stream postingan oleh user tertentu ---
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: userId) // Filter berdasarkan authorId
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }
  // --- AKHIR BARIS BARU ---

  Future<void> addPost({
    XFile? imageFile,
    String? caption,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in.");
    }

    UserModel? authorData = await _authService.getUserData(currentUser.uid);
    if (authorData == null) {
      throw Exception("Author data not found.");
    }

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }

    PostModel newPost = PostModel(
      id: '',
      authorId: currentUser.uid,
      authorUsername: authorData.email.split('@')[0],
      authorFullName: authorData.fullName ?? 'Pengguna AltarLink',
      authorProfileImageUrl: authorData.profileImageUrl,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: Timestamp.now(),
      likes: [],
      commentCount: 0,
    );

    await _firestore.collection('posts').add(newPost.toFirestore());
  }

  Future<void> toggleLike(
      {required String postId, required String userId}) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      List<String> currentLikes =
          List<String>.from(postSnapshot.get('likes') ?? []);

      if (currentLikes.contains(userId)) {
        currentLikes.remove(userId);
      } else {
        currentLikes.add(userId);
      }

      transaction.update(postRef, {'likes': currentLikes});
    });
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('posts').doc(postId).update(data);
    } on FirebaseException catch (e) {
      print("Firebase Firestore Error in updatePost: ${e.code} - ${e.message}");
      throw Exception("Gagal memperbarui postingan: ${e.code} - ${e.message}");
    } catch (e) {
      print("General Error in updatePost: $e");
      throw Exception(
          "Terjadi kesalahan saat memperbarui postingan: ${e.toString()}");
    }
  }

  Future<void> deletePost(String postId) async {
    // TODO: Tambahkan logika untuk menghapus gambar dari Storage jika diperlukan (opsional)
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } on FirebaseException catch (e) {
      print("Firebase Firestore Error in deletePost: ${e.code} - ${e.message}");
      throw Exception("Gagal menghapus postingan: ${e.code} - ${e.message}");
    } catch (e) {
      print("General Error in deletePost: $e");
      throw Exception(
          "Terjadi kesalahan saat menghapus postingan: ${e.toString()}");
    }
  }
}
