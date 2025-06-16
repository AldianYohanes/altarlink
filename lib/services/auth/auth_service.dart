// lib/services/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:altarlink4/models/user_model.dart'; // Pastikan ini diimpor

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk memantau status autentikasi user
  Stream<User?> get user => _auth.authStateChanges();

  // Getter untuk mendapatkan pengguna yang sedang login saat ini (nullable)
  User? get currentUser => _auth.currentUser;

  // Fungsi Pendaftaran (Sign Up) dengan Email, Password, dan FullName
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        UserModel newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          fullName: fullName,
          role: 'Anggota', // Default role
          profileImageUrl: '', // Default empty profile image URL
          bio: 'Misdinar Gereja Maria Bunda Karmol', // Default bio
          createdAt: Timestamp.now(),
        );

        print(
            'Attempting to save user data to Firestore for UID: ${firebaseUser.uid}');
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toFirestore());
        print(
            'User data saved successfully to Firestore for UID: ${firebaseUser.uid}');

        return firebaseUser;
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error SIGNUP: ${e.code} - ${e.message}");
      if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email sudah terdaftar.');
      }
      throw Exception('Gagal mendaftar: ${e.message}');
    } catch (e) {
      print("General Sign Up Error: $e");
      throw Exception('Terjadi kesalahan saat mendaftar: ${e.toString()}');
    }
    return null;
  }

  // Fungsi Login (Sign In)
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error SIGNIN: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found') {
        throw Exception('Pengguna tidak ditemukan.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah.');
      }
      throw Exception('Gagal login: ${e.message}');
    } catch (e) {
      print("General Sign In Error: $e");
      throw Exception('Terjadi kesalahan saat login: ${e.toString()}');
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      throw Exception('Gagal logout: ${e.toString()}');
    }
  }

  // Fungsi untuk mendapatkan data UserModel dari Firestore berdasarkan UID
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print("DEBUG: User data found for UID: $uid");
        return UserModel.fromFirestore(doc);
      } else {
        print("DEBUG: User document does NOT exist for UID: $uid");
        return null;
      }
    } on FirebaseException catch (e) {
      print(
          "DEBUG: Firebase Firestore Error in getUserData for UID $uid: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print(
          "DEBUG: General Error in getUserData for UID $uid: ${e.toString()}");
      return null;
    }
  }

  // Fungsi untuk memperbarui data pengguna di Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      print("User data updated successfully for UID: $uid");
    } on FirebaseException catch (e) {
      print(
          "Firebase Firestore Error in updateUserData for UID $uid: ${e.code} - ${e.message}");
      throw Exception('Gagal memperbarui data pengguna: ${e.message}');
    } catch (e) {
      print("General Error in updateUserData for UID $uid: ${e.toString()}");
      throw Exception(
          'Terjadi kesalahan saat memperbarui data pengguna: ${e.toString()}');
    }
  }

  // Fungsi untuk menghapus pengguna dari Firestore (bukan dari Auth)
  Future<void> deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print("User document deleted successfully for UID: $uid");
    } on FirebaseException catch (e) {
      print(
          "Firebase Firestore Error in deleteUserData for UID $uid: ${e.code} - ${e.message}");
      throw Exception('Gagal menghapus data pengguna: ${e.message}');
    } catch (e) {
      print("General Error in deleteUserData for UID $uid: ${e.toString()}");
      throw Exception(
          'Terjadi kesalahan saat menghapus data pengguna: ${e.toString()}');
    }
  }

  // Stream untuk mendapatkan semua pengguna (untuk Admin Panel)
  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // BARIS BARU: Fungsi untuk memperbarui peran pengguna (untuk Admin Panel)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
      print('User $uid role updated to $newRole');
    } catch (e) {
      print("Error updating user role: $e");
      throw Exception("Gagal memperbarui peran pengguna: ${e.toString()}");
    }
  }
}
