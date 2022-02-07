import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/app_user.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/users_provider.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:podcasts_app/util/utils.dart';

import 'package:provider/provider.dart';

import 'add_friends.dart';

class FriendsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendsState();
  }
}

class FriendsState extends State<FriendsPage> {
  final ValueNotifier<bool> loading = ValueNotifier(true);
  late final AppUser currentUser;
  late final AuthProvider auth;
  late final UsersProvider users;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    users = Provider.of<UsersProvider>(context, listen: false);

    currentUser = auth.currentUser!;
    users.fetchFriends(currentUser).then((value) => loading.value = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<UsersProvider>(builder: (context, users, _) {
        final friends = currentUser.friendsIds;
        final bool maxInvitesSent = currentUser.friendRequestsSentIds.length + friends.length == users.users.length;
        final friendRequests = currentUser.friendsRequestsIds;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkResponse(
                    child: Icon(
                      Icons.clear,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'Friends',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  InkResponse(
                    child: Icon(
                      Icons.person_add,
                      size: 30,
                      color: maxInvitesSent ? Colors.black26 : Theme.of(context).primaryColor,
                    ),
                    onTap: () => maxInvitesSent
                        ? null
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFriends(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: loading,
              builder: (context, loading, _) => loading
                  ? SizedProgressCircular()
                  : friendsList(
                      friends,
                      friendRequests,
                      UniqueKey(),
                    ),
            )
          ],
        );
      }),
    );
  }

  Widget friendsList(friends, friendRequests, key) {
    if (currentUser.friendRequestsSentIds.length + friends.length == users.users.length) return invitedEveryoneWidget;
    if (currentUser.friendsIds.isEmpty && friendRequests.isEmpty) return noFriendsWidget;

    return ListView(
      key: key,
      shrinkWrap: true,
      children: [
        ...friendRequests.map((id) =>
            users.getById(id) != null ? {friendCard(context, users.getById(id)!, isRequest: true)} : SizedBox()),
        ...friends.map((id) => users.getById(id) != null ? friendCard(context, users.getById(id)!) : SizedBox()),
      ],
    );
  }

  Widget friendCard(BuildContext context, AppUser user, {bool isRequest = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 2.3,
                    blurRadius: 3.0,
                    offset: Offset(1.0, 1.0),
                  )
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: user.photoUrl,
                  placeholder: (context, url) => Center(child: StyledProgressBar()),
                  errorWidget: (context, url, error) => Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 25,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Container(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${user.accountAge} days old',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            if (isRequest)
              InkResponse(
                onTap: () {
                  users.acceptFriendRequest(user);
                },
                child: Container(
                  width: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 0.5,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            if (isRequest)
              InkResponse(
                onTap: () {
                  users.declineFriendRequest(user);
                },
                child: Container(
                  width: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 0.5,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.clear,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget get noFriendsWidget => Column(
        children: [
          Text(
            "You don't have any friends yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10),
          MaterialButton(
            height: 40,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Theme.of(context).primaryColor,
            child: Text(
              'Add friends',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            disabledColor: Colors.grey,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddFriends(),
              ),
            ),
          ),
          TextButton(
            child: Text(
              'Share App',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );

  Widget get invitedEveryoneWidget => Column(
        children: [
          Text(
            "Congratulations! You have sent a friend \ninvite to the all users registered\n on Podcasting Together.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          TextButton(
            child: Text(
              'Invite new users',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
