import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/animations/fade_animation.dart';
import 'package:podcasts_app/components/category_card.dart';
import 'package:podcasts_app/components/podcast_card.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/screens/podcast_viewer.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: hasNotch ? 60 : 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffECE9E6),
              Theme.of(context).backgroundColor,
            ],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            stops: [0.0, 0.9],
            tileMode: TileMode.decal,
          ),
        ),
        child: Column(
          children: [
            Consumer<AuthProvider>(
              builder: (_, auth, __) => Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeAnimation(
                          2,
                          Text(
                            "Hi ${auth.currentUser!.username}, let's",
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        FadeAnimation(
                          6,
                          RichText(
                            text: TextSpan(
                                text: "Podcast ",
                                style: TextStyle(
                                  fontFamily: "Pacifico",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 27,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Together",
                                    style: TextStyle(
                                      fontFamily: "Pacifico",
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 28,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkResponse(
                    onTap: () async {
                      Provider.of<HomeProvider>(context, listen: false).switchToPage(HomeScreen.SETTINGS);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
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
                  SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
            Container(
              width: size.width,
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 5),
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => {},
                      decoration: InputDecoration(
                        hintText: 'Search',
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 160,
              child: ListView.builder(
                itemCount: PodcastCategory.values.length + 1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child:
                      index == PodcastCategory.values.length ? SizedBox() : CategoryCard(PodcastCategory.values[index]),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "View all",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Consumer<NetworkDataProvider>(
              builder: (_, data, __) => ListView.builder(
                itemCount: 6,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 25, right: 25),
                  child: index == 5
                      ? SizedBox(height: 30)
                      : data.finishedLoading
                          ? ElevatedButton(
                              style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(0),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
                              onPressed: () {
                                showCupertinoModalBottomSheet(
                                  barrierColor: Colors.black,
                                  topRadius: Radius.circular(20),
                                  context: context,
                                  builder: (_) => PodcastViewerPage(
                                    Podcast.dummy(),
                                  ),
                                );
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                child: PodcastCard(Podcast.dummy()),
                              ),
                            )
                          : PodcastCard(Podcast.dummy(), loading: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
