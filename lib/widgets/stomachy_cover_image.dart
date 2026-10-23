import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// ===============================================================
// STOMACHY COVER IMAGE
// Widget gambar sampul universal untuk semua konten.
// Mendukung 4 sumber sekaligus:
//   1. Base64 murni          -> hasil simpan form admin (Image.memory)
//   2. "data:image/...;base64," -> data URI (Image.memory)
//   3. URL http/https        -> Image.network
//   4. "assets/..."          -> Image.asset (data lama tetap tampil)
// Jika kosong / gagal, tampil icon fallback (tidak pernah error merah).
// ===============================================================

class StomachyCoverImage extends StatelessWidget {
  final String? imageSrc;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Color fallbackColor;
  final Color fallbackBackgroundColor;

  const StomachyCoverImage({
    super.key,
    required this.imageSrc,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.article_outlined,
    this.fallbackIconSize = 28,
    this.fallbackColor = const Color(0xFFB9543A),
    this.fallbackBackgroundColor = const Color(0xFFFFE7D8),
  });

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackBackgroundColor,
      child: Icon(
        fallbackIcon,
        size: fallbackIconSize,
        color: fallbackColor,
      ),
    );
  }

  Widget? _resolveImage() {
    final src = imageSrc?.trim() ?? '';
    if (src.isEmpty) return null;

    // 1) data URI base64
    if (src.startsWith('data:image')) {
      final commaIndex = src.indexOf(',');
      if (commaIndex != -1 && commaIndex + 1 < src.length) {
        try {
          return Image.memory(
            base64Decode(src.substring(commaIndex + 1)),
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    // 2) URL internet
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 3) asset bawaan aplikasi
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 4) base64 murni (hasil simpan dari form admin)
    final looksLikeBase64 = src.length > 200 &&
        !src.contains(' ') &&
        !src.contains('\n') &&
        RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(src);

    if (looksLikeBase64) {
      try {
        return Image.memory(
          base64Decode(src),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();
    if (image == null) return _buildFallback();
    return image;
  }

  // =============================================================
  // PICK + CROP GAMBAR SAMPUL (dipakai form admin)
  // Pilih dari galeri -> potong rasio 16:9 -> kompres ringan
  // agar aman disimpan sebagai base64 di Firestore (batas dok 1MB).
  // Mengembalikan bytes gambar final, atau null jika user batal.
  // =============================================================
  static Future<Uint8List?> pickAndCropCover() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );

    if (pickedFile == null) return null;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      maxWidth: 1080,
      maxHeight: 608,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Atur Gambar Sampul',
          toolbarColor: const Color(0xFFB05039),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFB05039),
          backgroundColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Atur Gambar Sampul',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile == null) return null;

    final bytes = await File(croppedFile.path).readAsBytes();
    return bytes;
  }
}