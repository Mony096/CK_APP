
class RowItem {
  final String left;
  final dynamic right; // can be Text or Icon
  final bool isRightIcon;

  RowItem({
    required this.left,
    this.right,
    this.isRightIcon = false,
  });
}
