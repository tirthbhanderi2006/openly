import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  BuildContext? _dialogContext;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((connectivityResults) {
      _updateConnectionStatus(connectivityResults);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResults) {
    final connectivityResult = connectivityResults.first;

    if (connectivityResult == ConnectivityResult.none) {
      if (_isConnected) {
        _isConnected = false;

        // Show dialog only if not connected
        if (_dialogContext == null) {
          _showConnectionDialog();
        }
      }
    } else {
      if (!_isConnected) {
        _isConnected = true;

        // Show Snackbar only when connection is restored
        Get.rawSnackbar(
          messageText: const Text(
            'YOU ARE NOW CONNECTED TO THE INTERNET',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          isDismissible: false,
          backgroundColor: Colors.green[400]!,
          icon: const Icon(
            Icons.wifi,
            color: Colors.white,
            size: 35,
          ),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED,
        );

        // Close the dialog if it was open
        if (_dialogContext != null) {
          Navigator.of(_dialogContext!).pop();
          _dialogContext = null;
        }
      }
    }
  }

  void _showConnectionDialog() {
    _dialogContext = Get.context; // Store the context for dialog
    showDialog(
      context: _dialogContext!,
      barrierDismissible: false, // Don't allow dismissing by tapping outside
      builder: (BuildContext context) {
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Column(
                children: [
                  Lottie.asset(
                    'lib/assets/no_internet.json', // Make sure to add this image to your assets
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No Internet Connection",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Please connect to the internet to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Check your Wi-Fi or mobile data connection.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
        );
      },
    );
  }

  bool get isConnected => _isConnected;
}
