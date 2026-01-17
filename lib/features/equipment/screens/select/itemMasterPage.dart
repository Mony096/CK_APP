import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemMasterPageBusiness extends StatefulWidget {
  const ItemMasterPageBusiness({super.key});

  @override
  State<ItemMasterPageBusiness> createState() => _ItemMasterPageBusinessState();
}

class _ItemMasterPageBusinessState extends State<ItemMasterPageBusiness> {
  final TextEditingController filter = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    filter.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final provider =
        Provider.of<ItemListProviderOffline>(context, listen: false);
    await provider.refreshDocuments();
  }

  void onPressed(dynamic bp) {
    Navigator.pop(context, bp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Select Item",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ItemListProviderOffline>(
        builder: (context, provider, _) {
          final documents = provider.documents;
          final isLoading = provider.isLoading;

          return Column(
            children: [
              // Search Bar Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: filter,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: const Color(0xFF1E293B)),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: "Search by name or code...",
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: Colors.grey.shade400, size: 22),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            provider.setFilter(value);
                            provider.loadDocuments();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        provider.setFilter(filter.text);
                        provider.loadDocuments();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "GO",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              // List View
              Expanded(
                child: isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF22C55E),
                          size: 45.0,
                        ),
                      )
                    : documents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  "No items found",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: documents.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final doc = documents[index];
                              return _buildItemCard(doc);
                            },
                          ),
              ),

              // Pagination Controls
              if (!isLoading && provider.totalPages > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          MediaQuery.of(context).size.width < 380
                              ? "Pg ${provider.currentPage}/${provider.totalPages} (${provider.totalRecords})"
                              : "Page ${provider.currentPage} of ${provider.totalPages} (${provider.totalRecords} total)",
                          style: GoogleFonts.inter(
                            fontSize: responsiveFontSize(context,
                                mobile: 11, tablet: 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          _buildPageButton(
                            icon: Icons.first_page_rounded,
                            onTap: provider.canPrev ? provider.firstPage : null,
                            isEnabled: provider.canPrev,
                          ),
                          const SizedBox(width: 8),
                          _buildPageButton(
                            icon: Icons.chevron_left_rounded,
                            onTap:
                                provider.canPrev ? provider.previousPage : null,
                            isEnabled: provider.canPrev,
                          ),
                          const SizedBox(width: 8),
                          _buildPageButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: provider.canNext ? provider.nextPage : null,
                            isEnabled: provider.canNext,
                          ),
                          const SizedBox(width: 8),
                          _buildPageButton(
                            icon: Icons.last_page_rounded,
                            onTap: provider.canNext ? provider.lastPage : null,
                            isEnabled: provider.canNext,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemCard(dynamic doc) {
    return InkWell(
      onTap: () => onPressed(doc),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withAlpha(15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF22C55E),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.inventory_rounded,
                color: Color(0xFF22C55E),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc["ItemName"] ?? "Unknown Item",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc["ItemCode"] ?? "N/A",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF22C55E)),
        ),
      ),
    );
  }
}

double responsiveFontSize(BuildContext context,
    {double mobile = 12, double tablet = 13, double desktop = 14}) {
  final double width = MediaQuery.of(context).size.width;

  if (width < 600) {
    return mobile; // Mobile
  } else if (width < 1024) {
    return tablet; // Tablet
  } else {
    return desktop; // Web / Desktop
  }
}
