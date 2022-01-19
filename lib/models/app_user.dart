import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  String _photoUrl;

  DateTime? registeredDate;

  Set<String> _friendsIds = {};
  Set<String> _friendRequestsIds = {};
  Set<String> _friendRequestsSentIds = {};

  AppUser._(this.id, this.email, this.username, this._photoUrl);

  String get photoUrl => _photoUrl;

  Set get friendsIds => Set.from(_friendsIds);

  Set get friendsRequestsIds => Set.from(_friendRequestsIds);

  Set get friendRequestsSentIds => Set.from(_friendRequestsSentIds);

  int get accountAge => registeredDate == null ? 0 : DateTime.now().difference(registeredDate!).inDays;

  void updatePhotoUrl(String url) => _photoUrl = url;

  void addFriend(String id) => _friendsIds.add(id);

  void removeFriend(String id) => _friendsIds.remove(id);

  void addFriendReq(String id) => _friendRequestsIds.add(id);

  void closeFriendReq(String id) => _friendRequestsIds.remove(id);

  void addFriendReqSent(String id) => _friendRequestsSentIds.add(id);

  void closeFriendReqSent(String id) => _friendRequestsSentIds.remove(id);

  bool isFriendOf(AppUser user) => _friendsIds.contains(user.id);

  factory AppUser.create(id, String email, String displayName, String photoURL) =>
      AppUser._(id, email, displayName, photoURL);

  factory AppUser.fromCredentials(User user) {
    return AppUser._(user.uid, user.email ?? "", user.displayName ?? "", user.photoURL ?? "");
  }

  factory AppUser.fromCloudStorage(Map<String, dynamic> data) {
    AppUser user = AppUser._(data["id"], data["email"], data["name"], data["photoUrl"] ?? "");
    user.registeredDate = DateTime.tryParse(data["register_timestamp"]);
    return user;
  }
}
