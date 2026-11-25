import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _persistPickedFile(XFile picked) async {
    final docs = await getApplicationDocumentsDirectory();
    final targetPath = '${docs.path}/avatar.jpg';
    final savedFile = await File(picked.path).copy(targetPath);

    await FileImage(savedFile).evict();

    if (!mounted) return;
    await context.read<SettingsModel>().setAvatarPath(savedFile.path);
  }

  Future<void> _chooseFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    await _persistPickedFile(picked);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        if (picked == null) return;
        await _persistPickedFile(picked);

      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera permission is needed to take a profile photo.',
            ),
          ),
        );

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        await _showPermissionDialog();
    }
  }

  Future<void> _showPermissionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Camera access disabled'),
          content: const Text(
            'Camera permission was permanently denied. Open app settings to enable it and take a profile photo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = context.watch<SettingsModel>().avatarPath;
    final avatarFile = avatarPath != null ? File(avatarPath) : null;
    final hasAvatar = avatarFile != null && avatarFile.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: hasAvatar ? FileImage(avatarFile) : null,
                child: hasAvatar
                    ? null
                    : const Text('U', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _chooseFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose photo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
