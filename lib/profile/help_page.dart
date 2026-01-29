import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import 'inquiry_page.dart';

// 이미지 확대 다이얼로그 위젯
class ImageZoomDialog extends StatelessWidget {
  final String imagePath;
  final String title;

  const ImageZoomDialog({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      key: ValueKey('image_zoom_dialog_$title'),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // 이미지
            Expanded(
              child: InteractiveViewer(
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.image_load_error, // 다국어 처리
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _currentPage = 0;
  late PageController _pageController;

  late List<HelpItem> helpItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 앱 로케일에 따라 각각 Title, Description을 다국어 적용함
    // 다국어 적용하기 위해 l10n는 build 함수 내에서 접근하므로 여기서는 임시 값 배열 만듦
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 다국어 텍스트를 가진 helpItems 배열 동적으로 생성
    helpItems = [
      HelpItem(
        title: l10n.help_intro_title,
        description: l10n.help_intro_description,
        imagePath: '',
        icon: Icons.help_outline,
        color: const Color(0xFF1E3A8A),
        isIntro: true,
      ),
      HelpItem(
        title: l10n.help_detailed_search_title,
        description: l10n.help_detailed_search_description,
        imagePath: 'lib/asset/1.png',
        icon: Icons.search,
        color: const Color(0xFF3B82F6),
        isIntro: false,
      ),
      HelpItem(
        title: l10n.help_timetable_title,
        description: l10n.help_timetable_description,
        imagePath: 'lib/asset/2.png',
        icon: Icons.schedule,
        color: const Color(0xFF10B981),
        isIntro: false,
      ),
      HelpItem(
        title: l10n.help_directions_title,
        description: l10n.help_directions_description,
        imagePath: 'lib/asset/3.png',
        icon: Icons.directions,
        color: const Color(0xFFF59E0B),
        isIntro: false,
      ),
      HelpItem(
        title: l10n.help_building_map_title,
        description: l10n.help_building_map_description,
        imagePath: 'lib/asset/4.png',
        icon: Icons.map,
        color: const Color(0xFF8B5CF6),
        isIntro: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.help),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  key: const ValueKey('help_page_view'),
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: helpItems.length,
                  itemBuilder: (context, index) {
                    final item = helpItems[index];
                    return _buildHelpCard(item, index);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    helpItems.length,
                    (index) => Container(
                      width: index == _currentPage ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentPage
                            ? const Color(0xFF1E3A8A)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              // 고객 지원 안내 (가이드라인 1.5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.contact_support_outlined,
                            color: const Color(0xFF1E3A8A),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.support_contact_title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.support_contact_description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const InquiryPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.mail_outline,
                            size: 18,
                            color: Color(0xFF1E3A8A),
                          ),
                          label: Text(
                            l10n.support_go_to_inquiry,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.previous, // 다국어 처리
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.only(left: _currentPage > 0 ? 8 : 0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < helpItems.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage < helpItems.length - 1
                                ? l10n.next
                                : l10n.done,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard(HelpItem item, int index) {
    return Container(
      key: ValueKey('help_card_$index'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: item.isIntro
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(item.icon, size: 60, color: item.color),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(flex: 3, child: _buildImageContent(item, context)),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 24,
                                  color: item.color,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4B5563),
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

 Widget _buildImageContent(HelpItem item, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return GestureDetector(
    key: ValueKey('image_content_${item.title}'),
    onTap: () {
      showDialog(
        context: context,
        builder: (context) =>
            ImageZoomDialog(imagePath: item.imagePath, title: item.title),
      );
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color.withOpacity(0.1),
                    item.color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.color.withOpacity(0.1),
                        item.color.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.image_load_error,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.zoom_in, color: item.color, size: 20),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class HelpItem {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color color;
  final bool isIntro;

  HelpItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.color,
    this.isIntro = false,
  });
}
