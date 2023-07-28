import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamaru_mobile_app/Controllers/User-Controller/userController.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class TopDetails extends StatelessWidget {
  const TopDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    return Container(
      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Column(
        children: [
          SizedBox(
              width: Get.width,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      )),
                  SizedBox(
                    width: Get.width * 0.5,
                  ),
                  Container(
                    height: 28,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 78, 78, 78).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Row(
                        children: [
                          LottieBuilder.asset(
                            "Assets/coin.json",
                            frameRate: FrameRate.max,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Obx(() => Text(
                                userController.totalCoins.value.toString(),
                                style: TextStyle(color: Colors.yellow),
                              ))
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
