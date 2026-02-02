import 'dart:io';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images =
            await _picker.pickMultiImage(imageQuality: 50);
        if (images.isNotEmpty) {
          if (!mounted) return;
          final provider = context.read<CompletedServiceProvider>();
          final int availableSlots = 4 - provider.images.length;

          int count = 0;
          for (var image in images) {
            if (count >= availableSlots) break;
            provider.addImage(File(image.path));
            count++;
          }

          if (images.length > count) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Maximum 4 images limit reached",
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        final XFile? image =
            await _picker.pickImage(source: source, imageQuality: 50);
        if (image != null) {
          if (!mounted) return;
          final provider = context.read<CompletedServiceProvider>();
          if (provider.images.length < 4) {
            provider.addImage(File(image.path));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Maximum 4 images allowed",
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageOptions() {
    if (context.read<CompletedServiceProvider>().images.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Maximum 4 images allowed",
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Capture Evidence",
                style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B))),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionItem(
                    Icons.camera_alt_rounded, "Camera", Colors.blue, () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                }),
                _buildOptionItem(
                    Icons.photo_library_rounded, "Gallery", Colors.purple, () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                }),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 1.h),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data["U_CK_Status"] ?? "Pending";
    final docNum = widget.data["DocNum"] ?? "N/A";
    final customerName = widget.data["CustomerName"] ?? "Unknown Customer";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Image Upload",
            style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          StatusStepper(status: status),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              children: [
                // JOB Summary Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle),
                        child: Icon(Icons.business_center_rounded,
                            color: const Color(0xFF425364), size: 18.sp),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customerName,
                                style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B))),
                            Text("JOB #$docNum",
                                style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ATTACHED IMAGES",
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 1.0)),
                      GestureDetector(
                        onTap: _showImageOptions,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEC4899),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Icon(Icons.add_a_photo_rounded,
                                  color: Colors.white, size: 14.sp),
                              SizedBox(width: 2.w),
                              Text("ADD NEW",
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Consumer<CompletedServiceProvider>(
                  builder: (context, provider, child) {
                    final images = provider.images;
                    if (images.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle),
                                child: Icon(Icons.image_not_supported_rounded,
                                    size: 30.sp,
                                    color: const Color(0xFFCBD5E1)),
                              ),
                              SizedBox(height: 2.h),
                              Text("No images captured yet",
                                  style: GoogleFonts.inter(
                                      fontSize: 14.5.sp,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3.w,
                        mainAxisSpacing: 3.w,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ImageCard(
                          key: ValueKey(images[index].path),
                          file: images[index],
                          index: index,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCard extends StatefulWidget {
  final File file;
  final int index;

  const ImageCard({super.key, required this.file, required this.index});

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeCard();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveRemark();
      }
    });
  }

  void _initializeCard() {
    // 1. Try get remark from provider
    final provider = context.read<CompletedServiceProvider>();
    String currentPath = widget.file.path;
    String remark = provider.imageRemarks[currentPath] ?? "";

    // 2. If empty, check migration from filename (legacy: image_REMARK_UniqueId)
    if (remark.isEmpty) {
      final name = currentPath.split(Platform.pathSeparator).last;
      if (name.startsWith("image_")) {
        // Expected format: image_REMARK_UniqueId.ext or image_UniqueId.ext
        // If it has 2 underscores after image_, it likely has a remark
        final content = name.substring("image_".length);
        final firstUnderscore = content.indexOf('_');

        if (firstUnderscore > 0) {
          // Found a remark in filename
          final legacyRemark = content.substring(0, firstUnderscore);
          final uniquePart = content.substring(firstUnderscore + 1);

          // We should migrate:
          // 1. Extract remark
          remark = legacyRemark;

          // 2. Rename file to remove remark (image_UniqueId.ext)
          // We do this asynchronously
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _migrateLegacyFile(currentPath, legacyRemark, uniquePart);
          });
        }
      }
    }

    _controller.text = remark;
  }

  Future<void> _migrateLegacyFile(
      String path, String remark, String uniquePart) async {
    try {
      String dir = path.substring(0, path.lastIndexOf(Platform.pathSeparator));
      // Reconstruct clean name
      String newName = "image_$uniquePart";
      // Note: uniquePart includes extension if it was at the end of legacy name

      // Rename
      final newPath = "$dir${Platform.pathSeparator}$newName";
      final file = File(path);
      if (await file.exists()) {
        final newFile = await file.rename(newPath);

        if (mounted) {
          final provider = context.read<CompletedServiceProvider>();
          // Update file reference in list (which also migrates map key if we used updateImage logic)
          // But since we are extracting remark separately, we set it manually
          provider.updateImage(widget.index, newFile);
          provider.setImageRemark(newPath, remark);
        }
      }
    } catch (e) {
      debugPrint("Migration failed: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveRemark() {
    final text = _controller.text.trim();
    context
        .read<CompletedServiceProvider>()
        .setImageRemark(widget.file.path, text);

    // Also ensure proper naming if still default pick (Sanitization)
    _ensureCleanFilename();
  }

  Future<void> _ensureCleanFilename() async {
    // Ensure file is named image_UniqueId.ext instead of image_picker_...
    // This is just for cleanliness, not critical for the remark logic anymore.
    String path = widget.file.path;
    String name = path.split(Platform.pathSeparator).last;

    // Only rename if it looks like a temporary picker file
    if (name.contains("image_picker") || name.startsWith("scaled_")) {
      String dir = path.substring(0, path.lastIndexOf(Platform.pathSeparator));
      String ext = "";
      if (name.contains('.')) {
        ext = name.substring(name.lastIndexOf('.'));
      }

      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      String newName = "image_$uniqueId$ext";
      String newPath = "$dir${Platform.pathSeparator}$newName";

      try {
        final file = File(path);
        final newFile = await file.rename(newPath);
        if (mounted) {
          context
              .read<CompletedServiceProvider>()
              .updateImage(widget.index, newFile);
          // The remark key migration in updateImage handles moving the remark to the new key
        }
      } catch (e) {
        debugPrint("Sanitization failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () =>
                        MaterialDialog.showImagePreview(context, widget.file),
                    child: Image.file(widget.file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => context
                          .read<CompletedServiceProvider>()
                          .removeImage(widget.index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 1.5.h),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Image title",
                hintStyle: GoogleFonts.inter(
                    fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                fillColor: const Color(0xFFF8FAFC),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF22C55E)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              onSubmitted: (_) {
                _focusNode.unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }
}
