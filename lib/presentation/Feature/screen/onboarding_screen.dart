import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';

import '../helper/global.dart';
import '../model/onboard.dart';
import '../widget/custom_btn.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PageController();

    final list = [
      // Onboarding 1
      Onboard(
        title: 'Ask me Anything',
        subtitle:
        'I can be your Best Friend & You can ask me anything & I will help you!',
        lottie: 'ai_ask_me',
      ),

      // Onboarding 2
      Onboard(
        title: 'Imagination to Reality',
        lottie: 'ai_play',
        subtitle:
        'Just Imagine anything & let me know, I will create something wonderful for you!',
      ),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: c,
        itemCount: list.length,
        itemBuilder: (ctx, ind) {
          final isLast = ind == list.length - 1;

          return Column(
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/lottie/${list[ind].lottie}.json',
                height: mq.height * .6,
                width: isLast ? mq.width * .7 : null,
              ),

              // Title
              Text(
                list[ind].title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),

              // Add some space
              SizedBox(height: mq.height * .015),

              // Subtitle
              SizedBox(
                width: mq.width * .7,
                child: Text(
                  list[ind].subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    letterSpacing: .5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              const Spacer(),

              // Dots indicator
              Wrap(
                spacing: 10,
                children: List.generate(
                  list.length,
                      (i) => Container(
                    width: i == ind ? 15 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == ind ? Colors.blue : Colors.grey,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Button
              CustomBtn(
                onTap: () {
                  if (isLast) {
                    Get.off(() => const HomeScreen());
                  } else {
                    c.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.ease,
                    );
                  }
                },
                text: isLast ? 'Finish' : 'Next',
              ),

              const Spacer(flex: 2),
            ],
          );
        },
      ),
    );
  }
}
