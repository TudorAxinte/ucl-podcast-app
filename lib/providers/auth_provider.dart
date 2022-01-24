import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import '../models/app_user.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _storage;
  AppUser? _currentUser;

  AuthProvider(this._auth, this._storage);

  AppUser? get currentUser => _currentUser;

  bool get isUserLoggedIn => _currentUser != null;

  Future<void> init({AppUser? user}) async {
    user != null
        ? _currentUser = user
        : _auth.currentUser == null
            ? _currentUser = null
            : _currentUser = AppUser.fromCredentials(_auth.currentUser!);

    if (_currentUser != null) await _fetchAuthServerData();
  }

  Future<void> _fetchAuthServerData() async {
    final usersRef = _storage.collection('users');
    final userId = _auth.currentUser!.uid;
    await usersRef.doc(userId).get().then((value) {
      _currentUser!.updateRegisterData(
        DateTime.parse(value.get("register_timestamp")),
      );
    });
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await init();
    notifyListeners();
  }

  Future<void> signInGoogle() async {
    final _googleSignIn = GoogleSignIn(scopes: ['email']);
    final signInAccount = await _googleSignIn.signIn();
    if (signInAccount != null) {
      final GoogleSignInAuthentication googleAuth = await signInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredentials = await _auth.signInWithCredential(credential);
      if (userCredentials.user != null) {
        if (userCredentials.user!.email != null) {
          if (await _isEmailAlreadyRegistered()) {
            await init();
          } else {
            await _auth.currentUser?.updateDisplayName(signInAccount.displayName ?? '');
            await _auth.currentUser?.updatePhotoURL(signInAccount.photoUrl ?? '');

            final usersRef = _storage.collection('users');
            final userId = _auth.currentUser!.uid;

            final Map<String, dynamic> data = {
              "id": userId,
              "name": signInAccount.displayName,
              "email": signInAccount.email,
              "photoUrl": signInAccount.photoUrl,
              "register_timestamp": DateTime.now().toString()
            };
            await usersRef.doc(userId).set(data);
            await init();
          }
        }
      }
    } else {
      throw FirebaseException(plugin: 'Google-Sign-In');
    }
  }

  Future<void> register(String name, String email, String password, {String? referralCode}) async {
    final usersRef = _storage.collection('users');
    if (referralCode != null) {
      final ref = usersRef.doc(referralCode);
      final referrer = await ref.get();
      if (!referrer.exists) throw ("The referral code entered is not valid.");
    }

    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _auth.currentUser!.updateDisplayName(name);

    final userId = _auth.currentUser!.uid;

    final Map<String, dynamic> data = {
      "id": userId,
      "name": name,
      "email": email,
      "register_timestamp": DateTime.now().toString()
    };
    await usersRef.doc(userId).set(data);

    await init();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> changeProfilePicture(File imageFile) async {
    final firebaseStorageRef = FirebaseStorage.instance.ref().child('users/${currentUser!.id}/avatar.jpg');
    final result = await firebaseStorageRef.putFile(await _compressImage(imageFile));
    final imageUrl = await result.ref.getDownloadURL();
    await _storage.collection("users").doc(currentUser!.id).update({"photoUrl": imageUrl});
    currentUser!.updatePhotoUrl(imageUrl);
    notifyListeners();
  }

  Future<File> _compressImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    final resize = img.copyResize(image!, width: 500);
    final avatar = File(imageFile.path);
    return await avatar.writeAsBytes(img.encodeJpg(resize, quality: 80));
  }

  Future<void> changePassword(String newPass, String oldPass) async {
    if (oldPass != newPass) throw ("Passwords must not match.");
    final result = await reAuthenticateToVerifyAccountOwnership(oldPass);
    if (result) {
      await _auth.currentUser!.updatePassword(newPass);
      notifyListeners();
    } else {
      throw FirebaseException(
        plugin: 'Login-Exception',
        message: 'Couldn\'t authenticate. Please, enter the correct password and try again.',
      );
    }
  }

  Future<bool> reAuthenticateToVerifyAccountOwnership(String password) async {
    bool success = false;
    await _auth.currentUser!
        .reauthenticateWithCredential(EmailAuthProvider.credential(email: _currentUser!.email, password: password))
        .then((value) {
      success = true;
    }).onError((error, stackTrace) {
      print("Failed to reAuthenticate with error $error");
    });
    return success;
  }

  Future<void> updateEmail(String email) async {
    if (email.isNotEmpty) await _auth.currentUser!.updateEmail(email);
    notifyListeners();
  }

  Future<void> requestPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> _isEmailAlreadyRegistered() async {
    final usersRef = _storage.collection('users');
    final userId = _auth.currentUser!.uid;
    final account = await usersRef.doc(userId).get();
    return account.exists;
  }

  bool get isSocialLogin => _auth.currentUser!.providerData
      .where(
        (element) => element.providerId == "google.com",
      )
      .isNotEmpty;
}
