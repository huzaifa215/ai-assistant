import 'package:alexa/model/radiomodel.dart';
import 'package:alexa/utilis/ai_utils_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = new AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRadios();
  }
  
  

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
    setState(() {});
  }

  _playMusic(String url){
    _audioPlayer.play(url);
    _selectedRadio=radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor1,
                    AIColors.primaryColor2,
                  ],
                  // make the gradiant position
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(), // .make  make it container
          AppBar(
            title: "Alexa".text.xl4.bold.white.bold.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),
          VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            itemBuilder: (context, index) {
              final rad = radios[index];
              return VxBox(
                      child: ZStack(
                [
                  Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: VxBox(
                              child: rad.category.text.uppercase.white
                                  .make()
                                  .px16())
                          .height(40)
                          .black
                          .alignCenter
                          .withRounded(value: 10.0)
                          .make()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VStack(
                      [
                        Text(
                          rad.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                        //rad.name.text.xl3.white.bold.make(),
                        5.heightBox,
                        rad.tagline.text.sm.white.semiBold.make(),
                        5.heightBox,

                        // the both are the same
                      ],
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: [
                      Icon(
                        CupertinoIcons.play_circle,
                        color: Colors.white,
                      ),
                      10.heightBox,
                      "Double Tap to Play".text.gray300.make(),
                    ].vStack(),
                  ),
                ],
              ))
                  .clip(Clip.antiAlias)
                  .bgImage(DecorationImage(
                      image: NetworkImage(rad.image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.darken)))
                  .border(color: Colors.black, width: 2.5)
                  .withRounded(value: 50.0)
                  .make()
                  .onInkDoubleTap(() {
                print("Helo");
              }).p16();
            },
          ).centered(),
          Padding(
            padding: EdgeInsets.only(bottom: context.percentHeight * 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                CupertinoIcons.stop_circle,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          )
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
