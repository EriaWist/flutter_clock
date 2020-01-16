import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:flukit/flukit.dart';
import 'container_hand.dart';
import 'drawn_hand.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  Size recordPlayerSize = Size(0, 0);
  GlobalKey _recordPlayerSizeKey = GlobalKey();

  _getContainerSize() {
    RenderBox _recordPlayerSizeBox =
        _recordPlayerSizeKey.currentContext.findRenderObject();
    // print('$recordPlayerSize'); /////////////////
    recordPlayerSize = _recordPlayerSizeBox.size;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.

    _updateTime();
    _updateModel();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getContainerSize());
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(milliseconds: 10),
        _updateTime,
      );
    });
  }

  var kedovalue = 0;
  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    WidgetsBinding.instance.addPostFrameCallback((_) => _getContainerSize());

    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_now);
    final minute = DateFormat('mm').format(_now);

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    // final weatherInfo = DefaultTextStyle(
    //   style: TextStyle(color: customTheme.primaryColor),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(_temperature),
    //       Text(_temperatureRange),
    //       Text(_condition),
    //       Text(_location),
    //     ],
    //   ),
    // );

    var nowSpeed = 0;
    if (_now.second + _now.millisecond / 1000 < 0.05) {
      nowSpeed = 0;
    } else {
      nowSpeed = 800;
    }
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        key: _recordPlayerSizeKey,
        color: Colors.transparent,
        child: Stack(
          children: [
            Image(
              image: AssetImage("images/background_light.png"),
            ),
            Positioned(
              //唱片陰影
              left: recordPlayerSize.width * 0.07,
              top: recordPlayerSize.height * 0.1,
              height: recordPlayerSize.height * 0.8,
              child: Image(
                image: AssetImage("images/record_shadow.png"),
              ),
            ),
            Positioned(
              //唱片
              left: recordPlayerSize.width * 0.05,
              top: recordPlayerSize.height * 0.1,
              height: recordPlayerSize.height * 0.8,
              child: TurnBox(
                turns: (_now.second + _now.millisecond / 1000) / 60.0,
                speed: nowSpeed,
                child: Image(
                  image: AssetImage("images/knob_light.png"),
                ),
              ),
            ),
            Positioned(
              //時間
              left: recordPlayerSize.width * 0.15,
              top: recordPlayerSize.height * 0.36,
              child: Text(
                '$hour : $minute',
                style: TextStyle(
                  fontFamily: 'CuteFont',
                  fontSize: recordPlayerSize.height * 0.2,
                  shadows: [
                    Shadow(
                      blurRadius: 0,
                      color: Colors.grey,
                      offset: Offset(5, 0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              //指針
              left: recordPlayerSize.width * 0.4,
              top: recordPlayerSize.height * 0.05,
              height: recordPlayerSize.height * 0.75,
              child: Image.asset(
                "images/Tonearm.png",
              ),
            ),
            Text('$recordPlayerSize'), ////////////////////
            Text('\n' + MediaQuery.of(context).size.toString()), ///////////
            Text('\n' +
                '\n' +
                '${_now.second.toDouble() + _now.millisecond / 1000}    ' +
                ' ${_now.second / 60}'), ////////////////////
            Positioned(
              //旋鈕陰影
              left: recordPlayerSize.width * 0.74,
              top: recordPlayerSize.height * 0.05,
              height: recordPlayerSize.height * 0.25,
              child: Image(
                image: AssetImage("images/knob_shadow_light.png"),
              ),
            ),
            Positioned(
              //旋鈕
              left: recordPlayerSize.width * 0.73,
              top: recordPlayerSize.height * 0.05,
              height: recordPlayerSize.height * 0.25,
              child: Stack(
                // alignment: AlignmentDirectional.topStart,
                children: <Widget>[
                  TurnBox(
                    turns: kedovalue / 100,
                    speed: 0,
                    child: Image.asset(
                      "images/knob_light.png",
                    ),
                  ),
                  SleekCircularSlider(
                    initialValue: 0,
                    appearance: CircularSliderAppearance(
                      angleRange: 270,
                      startAngle: 270,
                      size: recordPlayerSize.height * 0.25,
                      infoProperties: InfoProperties(),
                      customColors: CustomSliderColors(
                        dotColor: Colors.transparent,
                        progressBarColor: Colors.transparent,
                        trackColor: Colors.transparent,
                        hideShadow: true,
                      ),
                    ),
                    onChange: (double value) {
                      kedovalue = value.toInt();
                      setState(() {});
                      print(kedovalue);
                    },
                  ),
                  Text("$kedovalue"),
                ],
              ),
            ),
            Positioned(
              //拉桿
              left: recordPlayerSize.width * 0.7,
              top: recordPlayerSize.height * 0.35,
              width: recordPlayerSize.width * 0.2,
              height: recordPlayerSize.height * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: recordPlayerSize.height * 0.08,
                        width: recordPlayerSize.height * 0.1,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/print.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text("${_now.year % 100}"),
                      ),
                      Image.asset(
                        "images/track.png",
                        height: recordPlayerSize.height * 0.5,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Stack(
                      //   children: <Widget>[
                      //     Image.asset(
                      //       "../images/print.png",
                      //       height: recordPlayerSize.height * 0.08,
                      //     ),
                      //     Text("01"),
                      //   ],
                      // ),
                      Container(
                        height: recordPlayerSize.height * 0.08,
                        width: recordPlayerSize.height * 0.1,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/print.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text(_now.month < 10
                            ? "0${_now.month}"
                            : "${_now.month}"),
                      ),
                      Image.asset(
                        "images/track.png",
                        height: recordPlayerSize.height * 0.5,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: recordPlayerSize.height * 0.08,
                        width: recordPlayerSize.height * 0.1,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/print.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text(
                            _now.day < 10 ? "0${_now.day}" : "${_now.day}"),
                      ),
                      Stack(
                        children: <Widget>[
                          Image.asset(
                            "images/track.png",
                            height: recordPlayerSize.height * 0.5,
                          ),
                          Positioned(
                            top: recordPlayerSize.height * 0.5 * (10 / 31),
                            child: Image.asset(
                              "images/fader_d_light.png",
                              height: recordPlayerSize.height * 0.05,
                            ),
                          ),
                        ],
                      ),
                      // Container(
                      //   height: recordPlayerSize.height * 0.5,

                      //   // width: recordPlayerSize.height * 0.1,
                      //   alignment: Alignment.center,
                      //   decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //       image: AssetImage("images/track.png"),
                      //       fit: BoxFit.contain,
                      //     ),
                      //   ),
                      //   child: Image.asset(
                      //     "images/fader_d_light.png",
                      //     height: recordPlayerSize.height * 0.05,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Example of a hand drawn with [CustomPainter].
// DrawnHand(
//   color: customTheme.accentColor,
//   thickness: 4,
//   size: 1,
//   angleRadians: _now.second * radiansPerTick,
// ),
// DrawnHand(
//   color: customTheme.highlightColor,
//   thickness: 16,
//   size: 0.9,
//   angleRadians: _now.minute * radiansPerTick,
// ),
// // Example of a hand drawn with [Container].
// ContainerHand(
//   color: Colors.transparent,
//   size: 0.5,
//   angleRadians: _now.hour * radiansPerHour +
//       (_now.minute / 60) * radiansPerHour,
//   child: Transform.translate(
//     offset: Offset(0.0, -60.0),
//     child: Container(
//       width: 32,
//       height: 150,
//       decoration: BoxDecoration(
//         color: customTheme.primaryColor,
//       ),
//     ),
//   ),
// ),
// Positioned(
//   left: 0,
//   bottom: 0,
//   child: Padding(
//     padding: const EdgeInsets.all(8),
//     child: weatherInfo,
//   ),
// ),
