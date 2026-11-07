import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class UpdateService {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults({
        'app_version': '1.1.2',
        'force_update': false,
        'update_message':
            'A new version of SSES Solar Quotes is available. Please update to get the latest features and bug fixes.',
        'apk_url':
            'https://github.com/shazmah57/SSES-Solar-Quotes/releases/download/v1.1.3/app-release.apk',
        'whats_new':
            '• In-app download\n• No GitHub login needed\n• Bug fixes',
      });
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config init failed: $e');
    }
  }

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      await _remoteConfig.fetchAndActivate();

      final remoteVersion = _remoteConfig.getString('app_version');
      final forceUpdate = _remoteConfig.getBool('force_update');
      final updateMessage = _remoteConfig.getString('update_message');
      final apkUrl = _remoteConfig.getString('apk_url');
      final whatsNew = _remoteConfig.getString('whats_new');

      if (_isNewerVersion(remoteVersion, currentVersion)) {
        if (context.mounted) {
          _showUpdateDialog(
            context,
            updateMessage: updateMessage,
            forceUpdate: forceUpdate,
            apkUrl: apkUrl,
            whatsNew: whatsNew,
            newVersion: remoteVersion,
          );
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewerVersion(String remote, String current) {
    try {
      final remoteParts = remote.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      for (int i = 0; i < remoteParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (remoteParts[i] > currentParts[i]) return true;
        if (remoteParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void _showUpdateDialog(
    BuildContext context, {
    required String updateMessage,
    required bool forceUpdate,
    required String apkUrl,
    required String whatsNew,
    required String newVersion,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 10),
            Text('Update Available'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version $newVersion is available!',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(updateMessage),
              const SizedBox(height: 12),
              const Text(
                "What's new:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              ...whatsNew.split('\n').map((line) {
                if (line.trim().isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(line.trim(),
                      style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(apkUrl, context);
            },
            icon: const Icon(Icons.download),
            label: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(
      String apkUrl, BuildContext context) async {

    // 1. Request install permission
    final installPermission =
        await Permission.requestInstallPackages.request();
    if (!installPermission.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please allow installing from unknown sources')),
        );
      }
      return;
    }

    // 2. Get save path
    String savePath;
    try {
      final downloadsPath = '/storage/emulated/0/Download';
      final downloadFolder = Directory(downloadsPath);
      if (await downloadFolder.exists()) {
        savePath = '$downloadsPath/update.apk';
      } else {
        final tempDir = await getTemporaryDirectory();
        savePath = '${tempDir.path}/update.apk';
      }
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      savePath = '${tempDir.path}/update.apk';
    }

    final oldFile = File(savePath);
    if (await oldFile.exists()) await oldFile.delete();

    // 3. Progress variables (must be inside overlay builder)
    double progress = 0.0;
    String statusText = 'Connecting...';
    OverlayEntry? overlayEntry;

    // 4. Create overlay entry with progress inside builder
    overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Material(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Downloading Update...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress > 0 ? progress : null,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      progress > 0
                          ? '${(progress * 100).toStringAsFixed(0)}%'
                          : statusText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // 5. Insert the overlay
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry);

    try {
      // 6. Download using HttpClient
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);

      String downloadUrl = apkUrl;
      HttpClientResponse? response;

      for (int i = 0; i < 10; i++) {
        final request = await client.getUrl(Uri.parse(downloadUrl));
        request.headers.set('Accept', 'application/octet-stream');
        response = await request.close();

        if (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303 ||
            response.statusCode == 307 ||
            response.statusCode == 308) {
          downloadUrl = response.headers.value('location') ?? downloadUrl;
          await response.drain();
          continue;
        }
        break;
      }

      if (response == null || response.statusCode != 200) {
        throw Exception('HTTP ${response?.statusCode}');
      }

      final totalSize = response.contentLength;
      final file = File(savePath);
      final sink = file.openWrite();
      int received = 0;

      statusText = 'Downloading...';

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (totalSize > 0) {
          progress = received / totalSize;
          // Update overlay
          overlayEntry?.markNeedsBuild();
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      // 7. Close overlay
      overlayEntry?.remove();

      // 8. Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Update Downloaded'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The update has been downloaded successfully.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To install:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('1. Open your File Manager'),
                const Text('2. Navigate to your Downloads folder'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File: update.apk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${savePath.replaceAll('/update.apk', '')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('3. Tap "update.apk" and install'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  try {
                    OpenFile.open(savePath);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please open the APK manually from your Downloads folder.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open APK'),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      debugPrint('Download error: $e');
      overlayEntry?.remove();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}