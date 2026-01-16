// import 'dart:math' as math;
// import 'package:bizd_tech_service/core/utils/local_storage.dart';
// import 'package:bizd_tech_service/features/customer/provider/customer_list_provider.dart';
// import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
// import 'package:bizd_tech_service/features/equipment/provider/equipment_list_provider.dart';
// import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
// import 'package:bizd_tech_service/features/item/provider/item_list_provider.dart';
// import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
// import 'package:bizd_tech_service/features/site/provider/site_list_provider.dart';
// import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

// enum DownloadStatus { idle, downloading, completed, error }

// class DownloadItem {
//   final String name;
//   final IconData icon;
//   final Color color;
//   DownloadStatus status;
//   int downloaded;
//   int total;
//   String? error;

//   DownloadItem({
//     required this.name,
//     required this.icon,
//     required this.color,
//     this.status = DownloadStatus.idle,
//     this.downloaded = 0,
//     this.total = 0,
//     this.error,
//   });

//   double get progress => total > 0 ? downloaded / total : 0;
// }

// class DownloadScreen extends StatefulWidget {
//   const DownloadScreen({Key? key}) : super(key: key);

//   @override
//   State<DownloadScreen> createState() => _DownloadScreenState();
// }

// class _DownloadScreenState extends State<DownloadScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _rotationController;
//   late AnimationController _pulseController;
//   late AnimationController _waveController;

//   bool isDownloading = false;
//   bool allCompleted = false;
//   int currentIndex = -1;
//   String statusText = "Ready to sync master data";

//   final List<DownloadItem> items = [
//     DownloadItem(
//       name: "Customers",
//       icon: Icons.people_alt_rounded,
//       color: const Color(0xFF6366F1),
//     ),
//     DownloadItem(
//       name: "Items",
//       icon: Icons.category_rounded,
//       color: const Color(0xFFF59E0B),
//     ),
//     DownloadItem(
//       name: "Sites",
//       icon: Icons.location_city_rounded,
//       color: const Color(0xFF10B981),
//     ),
//     DownloadItem(
//       name: "Equipment",
//       icon: Icons.build_circle_rounded,
//       color: const Color(0xFFEC4899),
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat();

//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);

//     _waveController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     _pulseController.dispose();
//     _waveController.dispose();
//     super.dispose();
//   }

//   double get overallProgress {
//     if (items.isEmpty) return 0;
//     final completed =
//         items.where((i) => i.status == DownloadStatus.completed).length;
//     return completed / items.length;
//   }

//   Future<void> _startDownload() async {
//     if (isDownloading) return;

//     setState(() {
//       isDownloading = true;
//       allCompleted = false;
//       statusText = "Syncing...";
//       for (var item in items) {
//         item.status = DownloadStatus.idle;
//         item.downloaded = 0;
//         item.total = 0;
//         item.error = null;
//       }
//     });

//     try {
//       await _downloadCustomers();
//       await _downloadItems();
//       await _downloadSites();
//       await _downloadEquipment();

//       await LocalStorageManger.setString('isDownloaded', 'true');

//       setState(() {
//         isDownloading = false;
//         allCompleted = true;
//         statusText = "All data synced successfully!";
//       });
//     } catch (e) {
//       setState(() {
//         isDownloading = false;
//         statusText = "Sync failed. Tap to retry.";
//       });
//     }
//   }

//   Future<void> _downloadCustomers() async {
//     setState(() {
//       currentIndex = 0;
//       items[0].status = DownloadStatus.downloading;
//       statusText = "Downloading Customers...";
//     });

//     final online = Provider.of<CustomerListProvider>(context, listen: false);
//     final offline =
//         Provider.of<CustomerListProviderOffline>(context, listen: false);

//     await online.fetchDocumentOffline(
//         loadMore: false, isSetFilter: false, context: context);
//     await offline.saveDocuments(online.documentOffline);

//     setState(() {
//       items[0].status = DownloadStatus.completed;
//       items[0].downloaded = online.documentOffline.length;
//       items[0].total = online.documentOffline.length;
//     });
//   }

//   Future<void> _downloadItems() async {
//     setState(() {
//       currentIndex = 1;
//       items[1].status = DownloadStatus.downloading;
//       statusText = "Downloading Items...";
//     });

//     final online = Provider.of<ItemListProvider>(context, listen: false);
//     final offline =
//         Provider.of<ItemListProviderOffline>(context, listen: false);

//     await online.fetchDocumentOffline(
//         loadMore: false, isSetFilter: false, context: context);
//     await offline.saveDocuments(online.documentOffline);

//     setState(() {
//       items[1].status = DownloadStatus.completed;
//       items[1].downloaded = online.documentOffline.length;
//       items[1].total = online.documentOffline.length;
//     });
//   }

//   Future<void> _downloadSites() async {
//     setState(() {
//       currentIndex = 2;
//       items[2].status = DownloadStatus.downloading;
//       statusText = "Downloading Sites...";
//     });

//     final online = Provider.of<SiteListProvider>(context, listen: false);
//     final offline =
//         Provider.of<SiteListProviderOffline>(context, listen: false);

//     await online.fetchOfflineDocuments(loadMore: false, isSetFilter: false);
//     await offline.saveDocuments(online.documentOffline);

//     setState(() {
//       items[2].status = DownloadStatus.completed;
//       items[2].downloaded = online.documentOffline.length;
//       items[2].total = online.documentOffline.length;
//     });
//   }

//   Future<void> _downloadEquipment() async {
//     setState(() {
//       currentIndex = 3;
//       items[3].status = DownloadStatus.downloading;
//       statusText = "Downloading Equipment...";
//     });

//     final online = Provider.of<EquipmentListProvider>(context, listen: false);
//     final offline =
//         Provider.of<EquipmentOfflineProvider>(context, listen: false);

//     void onProgress() {
//       if (mounted) {
//         setState(() {
//           items[3].downloaded = online.fetchedCount;
//           items[3].total = online.totalCount;
//         });
//       }
//     }

//     online.addListener(onProgress);

//     try {
//       await online.fetchOfflineDocuments(loadMore: false, isSetFilter: false);
//       await offline.saveDocuments(online.documentOffline);

//       setState(() {
//         items[3].status = DownloadStatus.completed;
//         items[3].downloaded = online.documentOffline.length;
//         items[3].total = online.documentOffline.length;
//       });
//     } finally {
//       online.removeListener(onProgress);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF1E293B),
//               Color(0xFF0F172A),
//               Color(0xFF020617),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Custom AppBar
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap:
//                           isDownloading ? null : () => Navigator.pop(context),
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           color: isDownloading
//                               ? Colors.white.withOpacity(0.3)
//                               : Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       "Sync Data",
//                       style: GoogleFonts.inter(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const Spacer(),
//                     const SizedBox(width: 44),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Central Progress Circle
//               _buildCentralProgress(),

//               const SizedBox(height: 40),

//               // Download Items Grid
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   child: GridView.builder(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 12,
//                       childAspectRatio: 1.1,
//                     ),
//                     itemCount: items.length,
//                     itemBuilder: (context, index) =>
//                         _buildItemCard(items[index], index),
//                   ),
//                 ),
//               ),

//               // Action Button
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: _buildActionButton(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCentralProgress() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_rotationController, _pulseController]),
//       builder: (context, child) {
//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             // Outer glowing ring
//             if (isDownloading)
//               Container(
//                 width: 180 + (_pulseController.value * 20),
//                 height: 180 + (_pulseController.value * 20),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF3B82F6)
//                           .withOpacity(0.3 * _pulseController.value),
//                       blurRadius: 40,
//                       spreadRadius: 10,
//                     ),
//                   ],
//                 ),
//               ),

//             // Rotating gradient ring
//             if (isDownloading)
//               Transform.rotate(
//                 angle: _rotationController.value * 2 * math.pi,
//                 child: Container(
//                   width: 170,
//                   height: 170,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: SweepGradient(
//                       colors: [
//                         const Color(0xFF3B82F6).withOpacity(0),
//                         const Color(0xFF3B82F6),
//                         const Color(0xFF8B5CF6),
//                         const Color(0xFF3B82F6).withOpacity(0),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             // Background circle
//             Container(
//               width: 160,
//               height: 160,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF1E293B),
//                 border: Border.all(
//                   color: allCompleted
//                       ? const Color(0xFF22C55E)
//                       : Colors.white.withOpacity(0.1),
//                   width: 3,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (allCompleted)
//                     const Icon(
//                       Icons.check_circle_rounded,
//                       color: Color(0xFF22C55E),
//                       size: 50,
//                     )
//                   else if (isDownloading)
//                     ShaderMask(
//                       shaderCallback: (rect) => LinearGradient(
//                         colors: [
//                           const Color(0xFF3B82F6),
//                           const Color(0xFF8B5CF6),
//                         ],
//                       ).createShader(rect),
//                       child: Text(
//                         "${(overallProgress * 100).toInt()}%",
//                         style: GoogleFonts.inter(
//                           fontSize: 40,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                         ),
//                       ),
//                     )
//                   else
//                     Icon(
//                       Icons.cloud_download_rounded,
//                       color: Colors.white.withOpacity(0.8),
//                       size: 50,
//                     ),
//                   const SizedBox(height: 8),
//                   Text(
//                     allCompleted
//                         ? "Complete"
//                         : isDownloading
//                             ? "${items.where((i) => i.status == DownloadStatus.completed).length}/${items.length}"
//                             : "Tap to Sync",
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildItemCard(DownloadItem item, int index) {
//     final isActive = item.status == DownloadStatus.downloading;
//     final isCompleted = item.status == DownloadStatus.completed;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isActive
//               ? [
//                   item.color.withOpacity(0.3),
//                   item.color.withOpacity(0.1),
//                 ]
//               : isCompleted
//                   ? [
//                       const Color(0xFF22C55E).withOpacity(0.2),
//                       const Color(0xFF22C55E).withOpacity(0.05),
//                     ]
//                   : [
//                       Colors.white.withOpacity(0.08),
//                       Colors.white.withOpacity(0.03),
//                     ],
//         ),
//         border: Border.all(
//           color: isActive
//               ? item.color.withOpacity(0.5)
//               : isCompleted
//                   ? const Color(0xFF22C55E).withOpacity(0.5)
//                   : Colors.white.withOpacity(0.1),
//           width: 1.5,
//         ),
//         boxShadow: isActive
//             ? [
//                 BoxShadow(
//                   color: item.color.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ]
//             : null,
//       ),
//       child: Stack(
//         children: [
//           // Progress overlay
//           if (isActive && item.total > 0)
//             Positioned.fill(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(18),
//                 child: Align(
//                   alignment: Alignment.bottomCenter,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     height: (item.progress *
//                         MediaQuery.of(context).size.width /
//                         2.5),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: [
//                           item.color.withOpacity(0.4),
//                           item.color.withOpacity(0.1),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           // Content
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: isCompleted
//                             ? const Color(0xFF22C55E).withOpacity(0.2)
//                             : item.color.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         isCompleted ? Icons.check_rounded : item.icon,
//                         color:
//                             isCompleted ? const Color(0xFF22C55E) : item.color,
//                         size: 22,
//                       ),
//                     ),
//                     if (isActive)
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation(item.color),
//                         ),
//                       )
//                     else if (isCompleted)
//                       Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF22C55E),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 12,
//                         ),
//                       ),
//                   ],
//                 ),
//                 const Spacer(),
//                 Text(
//                   item.name,
//                   style: GoogleFonts.inter(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 if (isActive && item.total > 0)
//                   Text(
//                     "${item.downloaded} / ${item.total}",
//                     style: GoogleFonts.inter(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: item.color,
//                     ),
//                   )
//                 else if (isCompleted)
//                   Text(
//                     "${item.total} records",
//                     style: GoogleFonts.inter(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF22C55E),
//                     ),
//                   )
//                 else
//                   Text(
//                     "Waiting...",
//                     style: GoogleFonts.inter(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.5),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton() {
//     return GestureDetector(
//       onTap: isDownloading ? null : _startDownload,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: double.infinity,
//         height: 60,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: isDownloading
//               ? LinearGradient(
//                   colors: [
//                     Colors.grey[800]!,
//                     Colors.grey[700]!,
//                   ],
//                 )
//               : allCompleted
//                   ? const LinearGradient(
//                       colors: [
//                         Color(0xFF22C55E),
//                         Color(0xFF16A34A),
//                       ],
//                     )
//                   : const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Color(0xFF3B82F6),
//                         Color(0xFF8B5CF6),
//                       ],
//                     ),
//           boxShadow: [
//             BoxShadow(
//               color: allCompleted
//                   ? const Color(0xFF22C55E).withOpacity(0.4)
//                   : const Color(0xFF3B82F6).withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Center(
//           child: isDownloading
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         valueColor: AlwaysStoppedAnimation(
//                             Colors.white.withOpacity(0.8)),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       statusText,
//                       style: GoogleFonts.inter(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       allCompleted
//                           ? Icons.refresh_rounded
//                           : Icons.cloud_sync_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       allCompleted ? "Sync Again" : "Start Sync",
//                       style: GoogleFonts.inter(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }
