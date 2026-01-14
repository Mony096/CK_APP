import 'package:bizd_tech_service/features/service/providers/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/providers/service_list_provider_offline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String statusMessage = "Preparing download...";
  double progress = 0.0;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    
  }

  Future<void> _startDownload() async {
    final onlineProvider =
        Provider.of<ServiceListProvider>(context, listen: false);
    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    setState(() {
      isDownloading = true;
      progress = 0.0;
      statusMessage = "Starting download...";
    });

    try {
      // --- Step 1: Download Service Tickets ---
      setState(() {
        statusMessage = "Downloading Service Tickets...";
        progress = 0.25;
      });
      await onlineProvider.fetchDocumentTicket(
        loadMore: false,
        isSetFilter: false,
        context: context,
      );

      // --- Step 2: Save Service Tickets to offline storage ---
      setState(() {
        statusMessage = "Saving Service Tickets to offline storage...";
        progress = 0.5;
      });
      await offlineProvider.saveDocuments(onlineProvider.documentsTicket);

      await _fetchTicketCounts();

      // --- Step 3: Download Equipment (example, adjust to your API) ---
      setState(() {
        statusMessage = "Downloading Equipment...";
        progress = 0.75;
      });
      // await onlineProvider.fetchEquipment(context);

      // --- Step 4: Save Equipment ---
      setState(() {
        statusMessage = "Saving Equipment...";
        progress = 1.0;
      });
      // await offlineProvider.saveEquipment(onlineProvider.equipmentList);

      setState(() {
        isDownloading = false;
        statusMessage = "All documents downloaded successfully!";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All documents downloaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isDownloading = false;
        statusMessage = "Failed to download: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to download: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchTicketCounts() async {
    // your logic for fetching ticket counts
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text("Download Data")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            Text(
              "$statusMessage ($percent%)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isDownloading)
              ElevatedButton(
                onPressed: _startDownload,
                child: const Text("Download Again"),
              ),
          ],
        ),
      ),
    );
  }
}

