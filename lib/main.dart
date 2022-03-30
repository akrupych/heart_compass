import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_compass/main_cubit.dart';
import 'package:share_plus/share_plus.dart';

main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: BlocProvider(
            lazy: false,
            create: (context) => MainCubit(),
            child: BlocBuilder<MainCubit, MainState>(
                buildWhen: (previous, current) =>
                    previous.inLove != current.inLove,
                builder: (context, state) {
                  switch (state.inLove) {
                    case null:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      return const CompassPage();
                  }
                }),
          ),
        ),
      ),
    ),
  );
}

class CompassPage extends StatefulWidget {
  const CompassPage({Key? key}) : super(key: key);

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Tween<double> _tween = Tween(begin: 0.9, end: 1);
  final _textController = TextEditingController();

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: BlocConsumer<MainCubit, MainState>(
        listener: (context, state) {
          final myLocation = state.myLocation;
          final heartLocation = state.heartLocation;
          double distance = 0;
          if (myLocation != null && heartLocation != null) {
            distance = myLocation.getDistance(heartLocation);
            final heartUpdated =
                DateTime.fromMillisecondsSinceEpoch(heartLocation.timestamp);
            final now = DateTime.now();
            final difference = now.difference(heartUpdated);
            if (difference.compareTo(const Duration(minutes: 1)) > 0) {
              print("reset animation");
              _animationController.reset();
            } else {
              int duration = max(distance.round(), 1);
              print("duration: $duration");
              _animationController.duration = Duration(milliseconds: duration);
              _animationController.repeat();
            }
          }
        },
        builder: (context, state) {
          final myLocation = state.myLocation;
          final heartLocation = state.heartLocation;
          double bearing = 0;
          if (myLocation != null && heartLocation != null) {
            bearing = myLocation.getBearing(heartLocation);
          }
          double heading = state.heading ?? 0;
          double rotation = (bearing - heading) * pi / 180;
          bool inLove = state.inLove ?? false;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: rotation,
                child: Image.asset("assets/compass.png"),
              ),
              ScaleTransition(
                scale: _tween.animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.elasticOut)),
                child: Image.asset(
                  "assets/heart.png",
                  width: 150,
                ),
              ),
              Visibility(
                visible: !inLove,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.share,
                          ),
                          onPressed: () {
                            final userId =
                                context.read<MainCubit>().state.userId;
                            if (userId != null) Share.share(userId);
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextField(
                            controller: _textController,
                            cursorColor: Colors.black87,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: "Впиши сюди ID коханого/ї",
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.black87,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                          ),
                          onPressed: () {
                            context
                                .read<MainCubit>()
                                .fallInLove(_textController.text);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
