import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamaru_mobile_app/Screens/Wallet-Screens/RechargeDone.dart';
import 'package:gamaru_mobile_app/Screens/Wallet-Screens/withdrawComplete.dart';
import 'package:gamaru_mobile_app/Screens/Wallet-Screens/withdrawFaild.dart';
import 'package:gamaru_mobile_app/Screens/Wallet-Screens/withdrawl.dart';
import 'package:get/get.dart';

class WalletController extends GetxController {
  static WalletController get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  RxBool myWalletStatus = false.obs;
  TextEditingController adMoneyController = TextEditingController();
  TextEditingController withdrawMoneyController = TextEditingController();
  RxString fee = "0".obs;
  RxString toAccount = "0".obs;
  TextEditingController accountNoController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController ifscCodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController rechargeNoController = TextEditingController();

  RxList bankCardList = [].obs;
  var bankCardDetails = null;
  RxBool is_withdrawing = false.obs;

  addBankCard(
      accountNoorUPI, bankName, name, phoneNo, ifscCode, address) async {
    await _db
        .collection("user")
        .doc(user!.email.toString())
        .get()
        .then((value) async {
      List l = value["bankCards"];
      l.add({
        "accNoorUpi": accountNoorUPI,
        "bankName": bankName,
        "name": name,
        "phoneNO": phoneNo,
        "ifscCode": ifscCode,
        "address": address
      });
      await _db
          .collection("user")
          .doc(user!.email.toString())
          .update({"bankCards": l}).then((value) {
        Get.off(WithdrawScreen());
      });
    });
  }

  getBankCardList() {
    _db.collection("user").doc(user!.email.toString()).get().then((value) {
      List l = value["bankCards"];
      bankCardList.value = l;
      print(bankCardList.value);
    });
  }

  withdrawAmount(int amount, var card, int fee) async {
    is_withdrawing.value = true;
    try {
      print("in coin");
      await _db
          .collection("user")
          .doc(user!.email.toString())
          .get()
          .then((value) async {
        int winCoins = value["winCoins"];
        winCoins = winCoins - amount;
        print("in tranctions");
        await _db
            .collection("user")
            .doc(user!.email)
            .update({"winCoins": winCoins}).then((_) async {
          print("in getting");
          await _db
              .collection("user transactions")
              .doc(user!.email)
              .get()
              .then((v) async {
            print("in update");
            List transactionList = v["transactions"];
            transactionList.add({
              "amount": (amount - fee),
              "card": card,
              "email": user!.email,
              "reason": "Withdraw",
              "time": DateTime.now(),
              "fee": fee,
              "add": false
            });
            await _db
                .collection("user transactions")
                .doc(user!.email.toString())
                .update({"transactions": transactionList});
            await _db
                .collection("withdraw")
                .doc("all transactions")
                .update({"transactions": transactionList}).then((_) {
              Timer(Duration(milliseconds: 800), () {
                is_withdrawing.value = false;
                Get.to(WithdrawComplete());
              });
            });
          });
        });
      });
    } catch (e) {
      Get.to(WithdrawFailed());
    }
  }

  paymentSuccess(int amount) async {
    await _db
        .collection("user")
        .doc(user!.email.toString())
        .get()
        .then((v) async {
      bool rechargeFirst = v["rechargeFirst"];

      if (rechargeFirst) {
        await _db
            .collection("user")
            .doc(user!.email.toString())
            .get()
            .then((value) async {
          int coins = value["coins"];
          String referal = value["referal"];
          await _db
              .collection("ReferalAmount")
              .doc("refAmount")
              .get()
              .then((value1) async {
            int refReward = value1["amount"];

            await _db
                .collection("refId")
                .doc(referal)
                .get()
                .then((value2) async {
              String referalEmail = value2["email"];

              coins = coins + amount;

              await _db
                  .collection("user")
                  .doc(user!.email.toString())
                  .update({"coins": coins}).then((value) async {
                await _db
                    .collection("user transactions")
                    .doc(user!.email.toString())
                    .get()
                    .then((value) async {
                  List tList = value["transactions"];
                  tList.add({
                    "amount": amount,
                    "email": FirebaseAuth.instance.currentUser!.email,
                    "fee": 0,
                    "reason": "Recharge",
                    "time": DateTime.now(),
                    "add": true,
                  });

                  await _db
                      .collection("user transactions")
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .update({"transactions": tList}).then((value) async {
                    await _db
                        .collection("user")
                        .doc(user!.email.toString())
                        .get()
                        .then((value) async {
                      coins = value["coins"];
                      coins = coins + refReward;

                      await _db
                          .collection("user")
                          .doc(user!.email.toString())
                          .update({"coins": coins}).then((value) async {
                        await _db
                            .collection("user transactions")
                            .doc(user!.email.toString())
                            .get()
                            .then((value) async {
                          List tList = value["transactions"];
                          tList.add({
                            "amount": refReward,
                            "email": FirebaseAuth.instance.currentUser!.email,
                            "fee": 0,
                            "reason": "Referal Reward",
                            "time": DateTime.now(),
                            "add": true,
                          });

                          await _db
                              .collection("user transactions")
                              .doc(FirebaseAuth.instance.currentUser!.email)
                              .update({"transactions": tList}).then(
                                  (value) async {
                            await _db
                                .collection("user")
                                .doc(referalEmail)
                                .get()
                                .then((value) async {
                              int coins = value["coins"];
                              coins = coins + refReward;

                              await _db
                                  .collection("user")
                                  .doc(referalEmail)
                                  .update({"coins": coins}).then((value) async {
                                await _db
                                    .collection("user transactions")
                                    .doc(referalEmail)
                                    .get()
                                    .then((value) async {
                                  List tList = value["transactions"];
                                  tList.add({
                                    "amount": refReward,
                                    "email": referalEmail,
                                    "fee": 0,
                                    "reason": "Referal Reward",
                                    "time": DateTime.now(),
                                    "add": true,
                                  });

                                  await _db
                                      .collection("user transactions")
                                      .doc(referalEmail)
                                      .update({"transactions": tList}).then(
                                          (value) async {
                                    await _db
                                        .collection("user")
                                        .doc(user!.email.toString())
                                        .update({"rechargeFirst": false}).then(
                                            (value) {
                                      Get.to(() => const RechargeDone());
                                    });
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      } else {
        await _db
            .collection("user")
            .doc(user!.email.toString())
            .get()
            .then((value) async {
          int coins = value["coins"];
          coins = coins + amount;

          await _db
              .collection("user")
              .doc(user!.email.toString())
              .update({"coins": coins}).then((value) async {
            await _db
                .collection("user transactions")
                .doc(user!.email.toString())
                .get()
                .then((value) async {
              List tList = value["transactions"];
              tList.add({
                "amount": amount,
                "email": FirebaseAuth.instance.currentUser!.email,
                "fee": 0,
                "reason": "Recharge",
                "time": DateTime.now(),
                "add": true,
              });

              await _db
                  .collection("user transactions")
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .update({"transactions": tList}).then((value) {
                Get.to(() => const RechargeDone());
              });
            });
          });
        });
      }
    });
  }

  saveNumForRecharge(String nu) async {
    await _db
        .collection("user")
        .doc(user!.email.toString())
        .update({"rechargeNo": nu});
  }

  getNumForRecharge() async {
    await _db
        .collection("user")
        .doc(user!.email.toString())
        .get()
        .then((value) {
      rechargeNoController.text = value["rechargeNo"];
    });
  }
}
