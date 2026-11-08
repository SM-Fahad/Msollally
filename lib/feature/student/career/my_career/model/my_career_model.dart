class CareerItem {
  final String title;
  final String description;
  final String? icon; // <-- asset path
  final String? actionText;
  final void Function()? onTap;

  CareerItem({
    required this.title,
    required this.description,
    this.icon,
    this.actionText,
    this.onTap,
  });
}
