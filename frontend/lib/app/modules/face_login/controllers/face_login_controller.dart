import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class FaceLoginController extends GetxController {
  final GlobalAuthController _globalAuth = Get.find<GlobalAuthController>();

  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  RxBool isCameraInitialized = false.obs;
  RxBool isLoading = false.obs;
  RxString statusText = RxString('Mendeteksi...');
  Rx<Color> statusColor = const Color(0xFFFFF176).obs;
  RxBool isLoggedIn = false.obs;

  Timer? _checkTimer;
  DateTime _lastCheck = DateTime.now();
  static const int CHECK_INTERVAL_SECONDS = 2;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        statusText.value = 'Tidak ada kamera tersedia';
        statusColor.value = const Color(0xFFEF5350);
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      cameraController.value = controller;
      isCameraInitialized.value = true;

      _startPeriodicCheck();
    } catch (e) {
      statusText.value = 'Gagal mengakses kamera';
      statusColor.value = const Color(0xFFEF5350);
    }
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(
      const Duration(seconds: CHECK_INTERVAL_SECONDS),
      (_) async {
        if (isLoggedIn.value || isLoading.value) return;
        await _checkFace();
      },
    );
  }

  Future<Uint8List> _flipImageHorizontally(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset(-image.width.toDouble(), 0), Paint());

    final picture = recorder.endRecording();
    final flippedImage = await picture.toImage(image.width, image.height);
    final byteData = await flippedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _checkFace() async {
    if (cameraController.value == null || !isCameraInitialized.value) {
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastCheck).inSeconds < CHECK_INTERVAL_SECONDS) return;
    _lastCheck = now;

    try {
      isLoading.value = true;
      statusText.value = 'Memeriksa wajah...';
      statusColor.value = const Color(0xFFFFF176);

      final XFile photo = await cameraController.value!.takePicture();
      final File file = File(photo.path);
      final List<int> imageBytes = await file.readAsBytes();
      final Uint8List flippedBytes = await _flipImageHorizontally(Uint8List.fromList(imageBytes));
      final String base64Image = base64Encode(flippedBytes);

      await _globalAuth.loginWithFace(base64Image);

      isLoggedIn.value = true;
      statusText.value = 'Login Berhasil!';
      statusColor.value = const Color(0xFF66BB6A);

      _checkTimer?.cancel();

      await Future.delayed(const Duration(seconds: 1));
      Get.offNamedUntil(Routes.BERANDA, (route) => false);
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Tidak ada wajah terdeteksi')) {
        statusText.value = 'Tidak Ada Wajah';
        statusColor.value = const Color(0xFFFFF176);
      } else if (errorMsg.contains('Wajah belum terdaftar')) {
        statusText.value = 'Wajah Belum Terdaftar';
        statusColor.value = const Color(0xFFEF5350);
      } else if (errorMsg.contains('Belum ada wajah terdaftar')) {
        statusText.value = 'Belum Ada Wajah Terdaftar';
        statusColor.value = const Color(0xFFEF5350);
      } else {
        statusText.value = 'Error';
        statusColor.value = const Color(0xFFEF5350);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    _checkTimer?.cancel();
    Get.back();
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    cameraController.value?.dispose();
    super.onClose();
  }
}
