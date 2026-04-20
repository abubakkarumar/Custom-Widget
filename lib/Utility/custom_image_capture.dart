import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';

class CustomImageCapture {
  static Future<void> captureAndSave(
    GlobalKey repaintKey,
    BuildContext context,
  ) async {
    try {
      RenderRepaintBoundary boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        final result = await SaverGallery.saveImage(
          pngBytes,
          fileName: "ZayroExchange_${DateTime.now().millisecondsSinceEpoch}.png",
          skipIfExists: true,
        );

        if (!context.mounted) return;

        if (result.isSuccess) {
          CustomAnimationToast.show(
            message: "Image saved to gallery",
            context: context,
            type: ToastType.success,
          );
        } else {
          CustomAnimationToast.show(
            message: "Failed to save image",
            context: context,
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      debugPrint("Image capture error: $e");
    }
  }

  static Future<void> captureAndShare(
    GlobalKey repaintKey,
    BuildContext context,
  ) async {
    try {
      final pngBytes = await captureImageBytes(repaintKey);
      if (pngBytes == null) return;

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/ZayroExchange_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // final box = context.findRenderObject() as RenderBox?;

      final params = ShareParams(
        text: 'Scan the QR Code to get my AffiliateX Personal ID',
        files: [XFile(file.path)],
        // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        debugPrint('Thank you for sharing the picture!');
      }
    } catch (e) {
      debugPrint("Image capture share error: $e");
    }
  }

  static Future<Uint8List?> captureImageBytes(GlobalKey repaintKey) async {
    try {
      RenderRepaintBoundary boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing image bytes: $e");
      return null;
    }
  }
}
