import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/screens/home_tabs/settings_tabs/account_settings.dart';
import 'package:podcasts_app/screens/home_tabs/settings_tabs/faq.dart';
import 'package:podcasts_app/screens/home_tabs/settings_tabs/friends.dart';
import 'package:podcasts_app/screens/login.dart';
import 'package:podcasts_app/util/image_picker.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _loading = ValueNotifier(false);
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;
    final size = MediaQuery.of(context).size;

    return Consumer2<AuthProvider, HomeProvider>(builder: (context, auth, home, child) {
      return Loading(
        loading: _loading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: hasNotch ? 40 : 20),
              decoration: BoxDecoration(
                color: Colors.white,

              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkResponse(
                      onTap: () async {
                        _loading.value = true;
                        await auth.signOut().then((value) {
                          _loading.value = false;
                          Navigator.of(context).push(LoginPage.route());
                          home.reset();
                        }).onError((error, stackTrace) {
                          _loading.value = false;
                        });
                      },
                      child: Container(
                        width: 50,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
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
                          Icons.logout,
                          size: 20,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ),
                  InkResponse(
                    onTap: () async {
                      final result = await showDialogBox(context, ImagePicker(), 200.0, size.width * 0.5);
                      if (result != null) {
                        await auth.changeProfilePicture(result);
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      padding: const EdgeInsets.all(5),
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
                          imageUrl: auth.currentUser!.photoUrl,
                          placeholder: (context, url) => Center(child: StyledProgressBar()),
                          errorWidget: (context, url, error) => Padding(
                            padding: const EdgeInsets.all(25),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    auth.currentUser!.username,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.height * 0.03,
                    ),
                  ),
                  Text(
                    '${auth.currentUser!.accountAge} days old',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: size.height * 0.017,
                    ),
                  ),
                ],
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(
                0,
                -20,
                0,
              ),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    optionCard(
                      context,
                      "Account",
                      size,
                      Icons.person,
                      showCustomBottomSheet(context, AccountSettings(),
                          minHeight: size.height / 1.6, maxHeight: size.height),
                      subtitle: "Settings and information",
                    ),
                    optionCard(
                        context,
                        "Friends",
                        size,
                        Icons.group,
                        showCustomBottomSheet(context, FriendsPage(),
                            minHeight: size.height / 1.6, maxHeight: size.height),
                        subtitle: "Your network and friends"),
                    optionCard(
                      context,
                      "Frequently asked questions",
                      size,
                      Icons.perm_device_information_sharp,
                      showCustomBottomSheet(context, FaqPage(),
                          minHeight: size.height / 1.6, maxHeight: size.height / 1.6),
                      subtitle: "About the project",
                    ),
                    optionCard(
                      context,
                      "Share the app",
                      size,
                      Icons.share,
                      () => null,
                      subtitle: "Podcast together with your friends",
                    ),
                    optionCard(
                        context, "Contact us", size, Icons.email_outlined, () => launch("mailto:zcabtax@ucl.ac.uk"),
                        subtitle: "Get in touch"),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
