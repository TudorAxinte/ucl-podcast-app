import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/components/value_listanable_builder_2.dart';
import 'package:podcasts_app/models/app_user.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/users_provider.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:provider/provider.dart';

class AddFriends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddFriendsState();
  }
}

class AddFriendsState extends State<AddFriends> {
  final _selected = ValueNotifier<List<AppUser>>([]);
  final _search = ValueNotifier("");
  final _loading = ValueNotifier(false);
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    final users = Provider.of<UsersProvider>(context, listen: false);
    _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _selected.value = List.from(_currentUser!.friendRequestsSentIds.map((id) => users.getById(id)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;

    return Material(
      child: Loading(
        loading: _loading,
        child: Consumer<UsersProvider>(
          builder: (context, users, _) {
            final List appUsers = users.users;
            appUsers.remove(users.getById(_currentUser!.id));

            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                height: size.height * 0.2,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Theme.of(context).accentColor,
                child: Column(
                  children: [
                    SizedBox(height: hasNotch ? 40 : 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          'Add Friends',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selected,
                          builder: (context, loading, _) => TextButton(
                            child: Text(
                              'Send',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selected.value.isEmpty ? Colors.black26 : Colors.white,
                              ),
                            ),
                            onPressed: _selected.value.isEmpty
                                ? null
                                : () async {
                                    _loading.value = true;
                                    await Future.wait(
                                        _selected.value.map((user) async => await users.sendFriendRequest(user)));
                                    _loading.value = false;
                                    Navigator.of(context).pop();
                                  },
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87,
                              offset: Offset(0, 5),
                              spreadRadius: -4,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            Container(
                              width: size.width * 0.75,
                              padding: const EdgeInsets.only(left: 5),
                              child: TextFormField(
                                controller: TextEditingController(),
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) => _search.value = value,
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.black, fontSize: 17),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder2<dynamic, String>(
                  _selected,
                  _search,
                  builder: (context, loading, searched, _) {
                    appUsers.retainWhere((user) => user.username.toLowerCase().contains(searched.toLowerCase()));
                    appUsers.removeWhere((user) => _currentUser!.friendsIds.contains(user.id));
                    appUsers.removeWhere((user) => _currentUser!.friendRequestsSentIds.contains(user.id));

                    return appUsers.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            child: Text(
                              'No users matching "$searched" have been found.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView(
                      padding: EdgeInsets.zero,
                            children: appUsers.map((user) => userCard(context, user)).toList(),
                          );
                  },
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget userCard(BuildContext context, AppUser user) => InkWell(
        onTap: () {
          _selected.value.contains(user) ? _selected.value.remove(user) : _selected.value.add(user);
          _selected.notifyListeners();
        },
        child: Container(
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
                  child:CachedNetworkImage(
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
                width: 200,
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
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
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
                  child: _selected.value.contains(user) ? Icon(Icons.check) : SizedBox(),
                ),
              )
            ],
          ),
        ),
      );
}
