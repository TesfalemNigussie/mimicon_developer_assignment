import 'package:flutter/material.dart';

class Toast {
  Toast({required BuildContext context, required String message}) {
    _showCustomToast(context, message);
  }

  void _showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            child: Card(
              color: const Color(0x66000000),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 23, horizontal: 39),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}
