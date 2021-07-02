import 'package:alan_voice/alan_voice.dart';
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
    setUpAlan();
    // TODO: implement initState
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setUpAlan() {
    AlanVoice.addButton(
        // replace the key
        "9e01a2924f416714d9a862fcf1b4bafe2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

// data come in form of map
  _handleCommand(Map<String, dynamic> responce) {
    switch (responce["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final indexOfSelectedRadio = _selectedRadio.id;
        MyRadio newradioToPlay;
        if (indexOfSelectedRadio + 1 > radios.length) {
          // no radio left in list
          newradioToPlay = radios.firstWhere((element) => element.id == 1);
          radios.remove(newradioToPlay);
          radios.insert(0, newradioToPlay);
        } else {
          newradioToPlay = radios
              .firstWhere((element) => element.id == indexOfSelectedRadio + 1);
          radios.remove(newradioToPlay);
          radios.insert(0, newradioToPlay);
        }
        _playMusic(newradioToPlay.url);
        break;
      case "prev":
        final indexOfSelectedRadio = _selectedRadio.id;
        MyRadio newradioToPlay;
        if (indexOfSelectedRadio - 1 <= 0) {
          // no radio left in list
          newradioToPlay = radios.firstWhere((element) => element.id == 1);
          radios.remove(newradioToPlay);
          radios.insert(0, newradioToPlay);
        } else {
          newradioToPlay = radios
              .firstWhere((element) => element.id == indexOfSelectedRadio - 1);
          radios.remove(newradioToPlay);
          radios.insert(0, newradioToPlay);
        }
        _playMusic(newradioToPlay.url);
        break;
      case 'play_channel':
        final id = responce["id"];
        _audioPlayer.pause();
        MyRadio newradioToPlay =
            radios.firstWhere((element) => element.id == id);
        radios.remove(newradioToPlay);
        radios.insert(0, newradioToPlay);
        _playMusic(newradioToPlay.url);
        break;
      default:
        print("Command is ");
        print(responce["command"]);
        break;
    }
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color));
    print(radios);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    // to refresh the UI
    setState(() {});
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
                    AIColors.primaryColor2,
                    _selectedColor ?? AIColors.primaryColor1,
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
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1.0,
                  onPageChanged: (index) {
                    _selectedRadio = radios[index];
                    final colorHex = radios[index].color;
                    _selectedColor = Color(int.tryParse(colorHex));
                    setState(() {});
                  },
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
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken)))
                        .border(color: Colors.black, width: 2.5)
                        .withRounded(value: 50.0)
                        .make()
                        .onInkDoubleTap(() {
                      print("Play Music");
                      _playMusic(rad.url);
                    }).p16();
                  },
                ).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(bottom: context.percentHeight * 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isPlaying)
                  "Playing Now - ${_selectedRadio.name} FM"
                      .text
                      .white
                      .makeCentered(),
                Icon(
                  _isPlaying
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.play_circle,
                  color: Colors.white,
                  size: 40.0,
                ).onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    _playMusic(_selectedRadio.url);
                  }
                })
              ].vStack(),
            ),
          )
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
