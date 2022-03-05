import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/app_user.dart';

import 'auth_provider.dart';

class UsersProvider with ChangeNotifier {
  UsersProvider._internal();

  static final UsersProvider _singleton = UsersProvider._internal();

  factory UsersProvider(FirebaseFirestore storage) {
    _storage = storage;
    return _singleton;
  }

  static late AuthProvider _auth;
  static late FirebaseFirestore _storage;
  static bool _finishedLoading = false;
  static bool _loadedFriends = false;

  final Set<AppUser> _users = {};
  final Map<String, AppUser> _usersMap = {};

  Future<void> init() async {
    await fetchUsers();
    _finishedLoading = true;
    notifyListeners();
  }

  bool get loaded => _finishedLoading;

  bool get loadedFriends => _loadedFriends;

  List<AppUser> get users => List.from(_users);

  List<AppUser> get currentUserFriends =>
      loadedFriends && currentUser != null ? List<AppUser>.from(currentUser!.friendsIds.map((e) => getById(e))) : [];

  AppUser? get currentUser => _auth.currentUser;

  Future<void> fetchUsers() async {
    _users.clear();
    _usersMap.clear();
    final currentUser = _auth.currentUser;
    await _storage.collection("users").get().then((value) {
      value.docs.forEach((userData) {
        try {
          final AppUser user = AppUser.fromCloudStorage(userData.data());
          if (currentUser!.id != user.id) addUser(user);
        } catch (error) {
          print("Failed to add user ${userData.id}: $error");
        }
      });
    });
    notifyListeners();
  }

  Future<void> fetchFriends({AppUser? user}) async {
    if (user == null) user = _auth.currentUser;
    final userRef = _storage.collection("users").doc(user!.id);
    await userRef.collection("friends").get().then((value) {
      value.docs.forEach((friend) => user!.addFriend(friend.id));
    });
    await userRef.collection("friend_requests").get().then((value) {
      value.docs.forEach((request) => user!.addFriendReq(request.id));
    });
    await userRef.collection("friend_requests_sent").get().then((value) {
      value.docs.forEach((request) => user!.addFriendReqSent(request.id));
    });

    _loadedFriends = true;
    notifyListeners();
  }

  Future<void> sendFriendRequest(AppUser user) async {
    final currentUser = _auth.currentUser!;
    final usersRef = _storage.collection('users');
    final currentUserRef = usersRef.doc(currentUser.id);
    final targetUserRef = usersRef.doc(user.id);
    final sentTimestamp = DateTime.now().toString();

    await targetUserRef.collection("friend_requests").doc(currentUser.id).set({
      "time_sent": sentTimestamp,
    });
    await currentUserRef.collection("friend_requests_sent").doc(user.id).set({
      "time_sent": sentTimestamp,
    });

    currentUser.addFriendReqSent(user.id);
    notifyListeners();
  }

  Future<void> acceptFriendRequest(AppUser user) async {
    final currentUser = _auth.currentUser!;
    final usersRef = _storage.collection('users');
    final currentUserRef = usersRef.doc(currentUser.id);
    final targetUserRef = usersRef.doc(user.id);

    await targetUserRef.collection("friend_requests_sent").doc(currentUser.id).delete();
    await currentUserRef.collection("friend_requests").doc(user.id).delete();
    await targetUserRef.collection("friends").doc(currentUser.id).set({
      "name": currentUser.username,
      "email": currentUser.email,
      "id": currentUser.id,
    });
    await currentUserRef.collection("friends").doc(user.id).set({
      "name": user.username,
      "email": user.email,
      "id": user.id,
    });

    currentUser.closeFriendReq(user.id);
    currentUser.addFriend(user.id);
    notifyListeners();
  }

  Future<void> declineFriendRequest(AppUser user) async {
    final currentUser = _auth.currentUser!;
    final usersRef = _storage.collection('users');
    final currentUserRef = usersRef.doc(currentUser.id);
    final targetUserRef = usersRef.doc(user.id);
    await targetUserRef.collection("friend_requests_sent").doc(currentUser.id).delete();
    await currentUserRef.collection("friend_requests").doc(user.id).delete();
    currentUser.closeFriendReq(user.id);
    notifyListeners();
  }

  Future<void> removeFriend(AppUser user) async {
    final currentUser = _auth.currentUser!;
    final usersRef = _storage.collection('users');
    final currentUserRef = usersRef.doc(currentUser.id);
    final targetUserRef = usersRef.doc(user.id);
    await targetUserRef.collection("friends").doc(currentUser.id).delete();
    await currentUserRef.collection("friends").doc(user.id).delete();
    currentUser.removeFriend(user.id);
    notifyListeners();
  }

  void addUser(AppUser user) {
    _users.add(user);
    _usersMap.putIfAbsent(user.id, () => user);
    notifyListeners();
  }

  AppUser? getById(String id) {
    if (id == _auth.currentUser!.id) return _auth.currentUser;
    return _usersMap[id];
  }

  void updateAuth(AuthProvider auth) => _auth = auth;
}
