import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GrafanaDashboardScreen extends StatefulWidget {
  const GrafanaDashboardScreen({super.key});

  @override
  State<GrafanaDashboardScreen> createState() => _GrafanaDashboardScreenState();
}

class _GrafanaDashboardScreenState extends State<GrafanaDashboardScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Cập nhật progress bar nếu cần
              },
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                // Xử lý lỗi
                print('WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              'https://grafana.anhkiet.xyz/d/water-quality-monitoring-dashboard/water-quality-monitoring-dashboard?orgId=1&refresh=30s',
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Water Quality Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
