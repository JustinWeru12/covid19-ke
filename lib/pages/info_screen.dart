import 'package:covid19/pages/sidebar.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/style/theme.dart';
import 'package:covid19/widgets/my_header.dart';
import 'package:covid19/widgets/readmore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoScreen extends StatefulWidget {
  InfoScreen({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final logoutCallback;
  final String userId;

  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final controller = ScrollController();
  double offset = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, '/');
        return null;
      },
      child: Scaffold(
        drawer: SideBar(
          logoutCallback: widget._signOut,
        ),
        appBar: new AppBar(
          title: Text('About Covid', style: kAppBarstyle,),
          centerTitle: true,
          iconTheme: new IconThemeData(color: Colors.green),
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF3383CD),
                Color(0xFF11249F),
              ],
            )),
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyHeader(
                image: "assets/icons/coronadr.svg",
                textTop: "Get to know more",
                textBottom: "About Covid-19.",
                offset: offset,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Symptoms",
                      style: kTitleTextstyle,
                    ),
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SymptomCard(
                            image: "assets/images/headache.png",
                            title: "Headache",
                            isActive: true,
                          ),
                          SizedBox(width: 10),
                          SymptomCard(
                            image: "assets/images/caugh.png",
                            title: "Cough",
                          ),
                          SizedBox(width: 10),
                          SymptomCard(
                            image: "assets/images/fever.png",
                            title: "Fever",
                          ),
                          SizedBox(width: 10),
                          SymptomCard(
                            image: "assets/images/headache.png",
                            title: "Aches and Pains",
                            isActive: true,
                          ),
                          SizedBox(width: 10),
                          SymptomCard(
                            image: "assets/images/caugh.png",
                            title: "Shortness of Breath",
                          ),
                          SizedBox(width: 10),
                          SymptomCard(
                            image: "assets/images/fever.png",
                            title: "Nasal Congestion.",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Prevention", style: kTitleTextstyle),
                    SizedBox(height: 20),
                    PreventCard(
                      text:
                          "Since the start of the coronavirus outbreak some places have fully embraced wearing facemasks.The CDC now advises everyone to wear a cloth face cover when going out in public.",
                      image: "assets/images/wear_mask.png",
                      title: "Wear face mask",
                    ),
                    PreventCard(
                      text:
                          "Regularly and thoroughly clean your hands with an alcohol-based hand rub or wash them with soap and water to kill viruses that may be on your hands.",
                      image: "assets/images/wash_hands.png",
                      title: "Wash your hands",
                    ),
                    PreventCard(
                      text:
                          "Maintain at least 1 metre (3 feet) distance between yourself and anyone who is coughing or sneezing. If you are too close, you can breathe in the droplets, including the COVID-19 virus.",
                      image: "assets/images/wash_hands.png",
                      title: "Social Distance",
                    ),
                    PreventCard(
                      text:
                          "Stay at Home. If you have a fever, cough and difficulty breathing, seek medical attention and call in advance. Follow the directions of your local health authority(MOH).",
                      image: "assets/images/wash_hands.png",
                      title: "Isolate or Quarantine",
                    ),
                    PreventCard(
                      text:
                          "Clean and disinfect household surfaces daily and high-touch surfaces frequently throughout the day. High-touch surfaces include phones, remote controls, counters, tabletops, doorknobs, bathroom fixtures, toilets, keyboards, tablets and bedside tables.",
                      image: "assets/images/sanitize.png",
                      title: "Sanitize",
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PreventCard extends StatefulWidget {
  final String image;
  final String title;
  final String text;
  const PreventCard({
    Key key,
    this.image,
    this.title,
    this.text,
  }) : super(key: key);

  @override
  _PreventCardState createState() => _PreventCardState();
}

class _PreventCardState extends State<PreventCard> {
  @override
  Widget build(BuildContext context) {
    int lines= 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 156,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 136,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 8),
                    blurRadius: 24,
                    color: kShadowColor,
                  ),
                ],
              ),
            ),
            Image.asset(widget.image),
            Positioned(
              left: 130,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                height: 186,
                width: MediaQuery.of(context).size.width - 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: kTitleTextstyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: ReadMoreText(
                        widget.text,
                       trimLines: 3,
                  colorClickableText: Colors.blue,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' ...Read more',
                  trimExpandedText: ' Less',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          lines = 5;
                          print(lines);
                        });
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: SvgPicture.asset("assets/icons/forward.svg"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomCard extends StatelessWidget {
  final String image;
  final String title;
  final bool isActive;
  const SymptomCard({
    Key key,
    this.image,
    this.title,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          isActive
              ? BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 20,
                  color: kActiveShadowColor,
                )
              : BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  color: kShadowColor,
                ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Image.asset(image, height: 90),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
