import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/feature/pro_partners/help_support/controller/pro_partner_help_support_controller.dart';
import 'package:msollaally/feature/pro_partners/help_support/model/pro_partner_help_support_model.dart';
import 'package:msollaally/feature/student/health_wellness/screen/health_pdf_viewer.dart';

class ProPartnerHelpSupportScreen extends StatefulWidget {
  const ProPartnerHelpSupportScreen({super.key});

  @override
  State<ProPartnerHelpSupportScreen> createState() =>
      _ProPartnerHelpSupportScreenState();
}

class _ProPartnerHelpSupportScreenState
    extends State<ProPartnerHelpSupportScreen>
    with SingleTickerProviderStateMixin {
  final ProPartnerHelpSupportController controller = Get.put(
    ProPartnerHelpSupportController(),
  );
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhiteF5F7FB,
      appBar: const GlobalAppBar(title: 'Help & Support'),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryButtonColor,
              indicatorWeight: 3,
              labelColor: AppColors.primaryButtonColor,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'LinkYetu Support'),
                Tab(text: 'Emergency Support'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLinkYetuSupport(),
                _buildEmergencySupport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkYetuSupport() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.width),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'LinkYetu Partner Desk',
                        style: appTextStyleHeading1(
                          fontSize: 18.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.height),
                Text(
                  'We are here to help you get the most out of LinkYetu. Connect with our dedicated partner support team or explore video guides below.',
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.height),

          // Contact Details Section
          Text(
            'Direct Support Channels',
            style: appTextStyleHeading1(
              fontSize: 16.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarTitleColor,
            ),
          ),
          SizedBox(height: 12.height),
          _buildContactCard(
            icon: Icons.email_outlined,
            iconColor: Colors.blue,
            title: 'Email Support',
            subtitle: 'support@linkyetu.com',
            actionText: 'Send Email',
            onTap: () => _launchUrl('mailto:support@linkyetu.com?subject=Pro-Partner%20Support%20Request'),
          ),
          SizedBox(height: 10.height),
          _buildContactCard(
            icon: Icons.phone_in_talk_outlined,
            iconColor: Colors.green,
            title: 'Helpline & Telephone',
            subtitle: '+255 700 000 000 / +255 22 211 0000',
            actionText: 'Call Now',
            onTap: () => _launchUrl('tel:+255700000000'),
          ),
          SizedBox(height: 10.height),
          _buildContactCard(
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF25D366),
            title: 'WhatsApp Official Support',
            subtitle: '+255 700 000 000 (Instant replies)',
            actionText: 'Chat on WhatsApp',
            onTap: () => _launchUrl('https://wa.me/255700000000?text=Hello%20LinkYetu%20Support'),
          ),
          SizedBox(height: 10.height),
          _buildContactCard(
            icon: Icons.access_time_outlined,
            iconColor: Colors.orange,
            title: 'Working Hours',
            subtitle: 'Monday – Friday: 08:00 AM – 05:00 PM (EAT)',
          ),
          SizedBox(height: 24.height),

          // Instructional Video Guides
          Text(
            'Instructional Video Guides',
            style: appTextStyleHeading1(
              fontSize: 16.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarTitleColor,
            ),
          ),
          SizedBox(height: 6.height),
          Text(
            'Learn how to manage campaigns, post jobs, and engage students effectively.',
            style: getTextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          SizedBox(height: 12.height),
          _buildTutorialVideoCard(
            title: '1. Creating & Targeting Campaigns',
            description: 'Learn how to reach specific university students, majors, and study years.',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            duration: '3m 45s',
          ),
          SizedBox(height: 12.height),
          _buildTutorialVideoCard(
            title: '2. Posting & Managing Job Listings',
            description: 'Step-by-step tutorial on formatting responsibilities, experience levels, and tracking applications.',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
            duration: '4m 12s',
          ),
          SizedBox(height: 12.height),
          _buildTutorialVideoCard(
            title: '3. Hosting Campus Events & RSVPs',
            description: 'Set up event details, upload cover banners, and monitor attendee registrations.',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
            duration: '2m 50s',
          ),
          SizedBox(height: 24.height),

          // FAQs
          Text(
            'Frequently Asked Questions',
            style: appTextStyleHeading1(
              fontSize: 16.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarTitleColor,
            ),
          ),
          SizedBox(height: 12.height),
          _buildFaqItem(
            question: 'How does university and major targeting work?',
            answer: 'When creating a Campaign, you can choose specific universities or "All Universities", and select target majors. Only students whose verified profile matches your targeting criteria will see the campaign on their Campus feed.',
          ),
          _buildFaqItem(
            question: 'Is there a subscription fee for Pro-Partners?',
            answer: 'No. Pro-Partners register from the app and receive approval directly from the LinkYetu Admin Portal. There are no recurring subscription charges.',
          ),
          _buildFaqItem(
            question: 'How do I know when students message me?',
            answer: 'You will receive instant push notifications and socket updates in the app. New conversations are counted in the "New Messages" badge on your dashboard.',
          ),
          _buildFaqItem(
            question: 'What video file formats and sizes are supported?',
            answer: 'We support MP4 and WebM video formats up to 50MB. You can also paste direct YouTube or video URLs.',
          ),
          SizedBox(height: 30.height),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(14.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 14.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.appBarTitleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null && actionText != null)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryButtonColor,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                actionText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTutorialVideoCard({
    required String title,
    required String description,
    required String videoUrl,
    required String duration,
  }) {
    return _TutorialCard(
      title: title,
      description: description,
      videoUrl: videoUrl,
      duration: duration,
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.appBarTitleColor,
          ),
        ),
        childrenPadding: EdgeInsets.fromLTRB(16.width, 0, 16.width, 14.height),
        children: [
          Text(
            answer,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySupport() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.width),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: controller.searchSupport,
        decoration: InputDecoration(
          hintText: 'Search emergency services & contacts...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      controller.clearSearch();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: const BorderSide(color: AppColors.appBarTitleColor),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(vertical: 12.height),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.supportList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.supportList.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshSupport,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 100.height),
              Center(
                child: Text(
                  controller.searchQuery.value.isNotEmpty
                      ? "No support information found for '${controller.searchQuery.value}'."
                      : "No emergency support contacts found.",
                  style: getTextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshSupport,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.width),
          itemCount: controller.supportList.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.supportList.length) {
              return controller.isLoadingMore.value
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.height),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final item = controller.supportList[index];
            return ExpandableSupportCard(item: item);
          },
        ),
      );
    });
  }
}

class _TutorialCard extends StatefulWidget {
  final String title;
  final String description;
  final String videoUrl;
  final String duration;

  const _TutorialCard({
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
  });

  @override
  State<_TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<_TutorialCard> {
  bool _showPlayer = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(14.width),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appBarTitleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.duration,
                              style: getTextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showPlayer = !_showPlayer;
                    });
                  },
                  icon: Icon(
                    _showPlayer ? Icons.close : Icons.play_circle_fill,
                    color: AppColors.primaryButtonColor,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          if (_showPlayer)
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14.radius)),
              child: Container(
                color: Colors.black,
                child: InlineVideoPlayerWidget(url: widget.videoUrl),
              ),
            ),
        ],
      ),
    );
  }
}

class ExpandableSupportCard extends StatefulWidget {
  final ProPartnerHelpSupportModel item;

  const ExpandableSupportCard({super.key, required this.item});

  @override
  State<ExpandableSupportCard> createState() => _ExpandableSupportCardState();
}

class _ExpandableSupportCardState extends State<ExpandableSupportCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _extractPdf(String url) {
    Get.to(() => HealthPdfViewer(url: url, title: widget.item.title ?? 'PDF Document'));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.height),
      elevation: _isExpanded ? 3 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.radius),
        side: BorderSide(
          color: _isExpanded ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _toggleExpand,
              borderRadius: _isExpanded
                  ? BorderRadius.vertical(top: Radius.circular(16.radius))
                  : BorderRadius.circular(16.radius),
              child: Padding(
                padding: EdgeInsets.all(16.width),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title ?? 'No Title',
                            style: appTextStyleHeading1(
                              fontSize: 16.fontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black1F1F1F,
                            ),
                          ),
                          if (!_isExpanded) ...[
                            SizedBox(height: 6.height),
                            Text(
                              widget.item.description ?? '',
                              style: appTextStyleHeading1(
                                fontSize: 13.fontSize,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: EdgeInsets.fromLTRB(16.width, 0, 16.width, 16.height),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey.shade200),
                    SizedBox(height: 8.height),

                    // Tags
                    Wrap(
                      spacing: 8.width,
                      runSpacing: 8.height,
                      children: [
                        if (widget.item.type != null &&
                            widget.item.type!.isNotEmpty)
                          _buildMetaChip(widget.item.type!, Colors.blue),
                        if (widget.item.supportType != null &&
                            widget.item.supportType!.isNotEmpty)
                          _buildMetaChip(
                            widget.item.supportType!,
                            Colors.green,
                          ),
                      ],
                    ),
                    if (widget.item.type != null ||
                        widget.item.supportType != null)
                      SizedBox(height: 12.height),

                    // Full Description
                    Text(
                      widget.item.description ?? '',
                      style: appTextStyleHeading1(
                        fontSize: 14.fontSize,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16.height),

                    // Image
                    if (widget.item.imageUrl != null &&
                        widget.item.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.radius),
                        child: Image.network(
                          widget.item.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      SizedBox(height: 16.height),
                    ],

                    // Inline Video Player
                    if (widget.item.videoUrl != null &&
                        widget.item.videoUrl!.isNotEmpty) ...[
                      Text(
                        "Video Guide",
                        style: appTextStyleHeading1(
                          fontSize: 14.fontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black1F1F1F,
                        ),
                      ),
                      SizedBox(height: 8.height),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.radius),
                        child: Container(
                          color: Colors.black,
                          child: InlineVideoPlayerWidget(
                            url: widget.item.videoUrl!,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.height),
                    ],

                    // Extract/Download PDF Button
                    if (widget.item.pdfUrl != null &&
                        widget.item.pdfUrl!.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _extractPdf(widget.item.pdfUrl!),
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Extract / View PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12.height),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.radius),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 4.height),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8.radius),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        label.capitalizeFirst ?? label,
        style: appTextStyleHeading1(
          fontSize: 11.fontSize,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}

// Inline Video Player Widget to handle initialization gracefully within list items
class InlineVideoPlayerWidget extends StatefulWidget {
  final String url;
  const InlineVideoPlayerWidget({super.key, required this.url});

  @override
  State<InlineVideoPlayerWidget> createState() =>
      _InlineVideoPlayerWidgetState();
}

class _InlineVideoPlayerWidgetState extends State<InlineVideoPlayerWidget> {
  VideoPlayerController? _controller;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (videoId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize()
            .then((_) {
              if (mounted) setState(() {});
            })
            .catchError((e) {
              if (mounted) setState(() => _hasError = true);
            });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isYoutube && _youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
      );
    }

    if (_hasError) {
      return Container(
        height: 200,
        color: Colors.grey.shade900,
        child: const Center(
          child: Text(
            "Error loading video",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller!),
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _controller!.value.isPlaying
                    ? const SizedBox.shrink()
                    : Container(
                        color: Colors.black45,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 60.0,
                          ),
                        ),
                      ),
              ),
            ),
            VideoProgressIndicator(_controller!, allowScrubbing: true),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
