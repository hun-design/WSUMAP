import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../generated/app_localizations.dart';
import '../services/inquiry_service.dart';
import '../auth/user_auth.dart';
import 'inquiry_detail_page.dart';

class InquiryPage extends StatefulWidget {
  final UserAuth userAuth;

  const InquiryPage({required this.userAuth, super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_MyInquiriesTabState> _myInquiriesTabKey =
      GlobalKey<_MyInquiriesTabState>();
  
  // 🔥 위젯 생명주기 관리
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.inquiry,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E3A8A),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF1E3A8A),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          tabs: [
            Tab(text: l10n.inquiry),
            Tab(text: l10n.my_inquiry),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 문의하기 탭
          CreateInquiryTab(
            userAuth: widget.userAuth,
            onInquirySubmitted: () {
              // 문의 등록 성공 후 "내 문의" 탭 새로고침
              _myInquiriesTabKey.currentState?.refreshInquiries();
            },
          ),
          // 내 문의 탭
          MyInquiriesTab(key: _myInquiriesTabKey, userAuth: widget.userAuth),
        ],
      ),
    );
  }
}

// 문의하기 탭
class CreateInquiryTab extends StatefulWidget {
  final UserAuth userAuth;
  final VoidCallback? onInquirySubmitted;

  const CreateInquiryTab({
    required this.userAuth,
    this.onInquirySubmitted,
    super.key,
  });

  @override
  State<CreateInquiryTab> createState() => _CreateInquiryTabState();
}

class _CreateInquiryTabState extends State<CreateInquiryTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedInquiryType;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // 🔥 제출 상태 관리 추가
  bool _isSubmitting = false;
  
  // 🔥 위젯 생명주기 관리
  bool _isDisposed = false;

  // 🔥 문의 유형 매핑 (한국어 코드 ↔ 다국어 텍스트)
  late Map<String, String> _inquiryTypeMapping;

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 서버 경로 테스트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testServerRoutes();
    });
  }

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_isDisposed) return;

  final l10n = AppLocalizations.of(context)!;

  _inquiryTypeMapping = {
    'place_error': l10n.inquiry_category_place_error,
    'bug': l10n.inquiry_category_bug,
    'feature': l10n.inquiry_category_feature,
    'route_error': l10n.inquiry_category_route_error,
    'other': l10n.inquiry_category_other,
  };

  debugPrint('=== 문의 카테고리 매핑 설정 ===');
  debugPrint('현재 언어: ${Localizations.localeOf(context)}');
  debugPrint('현재 로컬라이제이션 타입: ${l10n.runtimeType}');
  debugPrint('매핑 상세 확인:');
  _inquiryTypeMapping.forEach((key, value) {
    debugPrint('  키: "$key" -> 값: "$value"');
  });
  debugPrint('============================');
  
}


  /// 서버 경로 테스트
  void _testServerRoutes() {
    if (widget.userAuth.userId != null) {
      InquiryService.testServerRoutes(widget.userAuth.userId!);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 문의 유형 선택
              _buildInquiryTypeSection(),
              const SizedBox(height: 24),

              // 제목 입력
              _buildTitleSection(),
              const SizedBox(height: 24),

              // 내용 입력
              _buildContentSection(),
              const SizedBox(height: 24),

              // 이미지 첨부
              _buildImageAttachmentSection(),
              const SizedBox(height: 32),

              // 제출 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitInquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.inquiry_submit,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 개인정보 처리방침 버튼
              Center(
                child: TextButton.icon(
                  onPressed: () => _openPrivacyPolicy(),
                  icon: const Icon(
                    Icons.privacy_tip_outlined,
                    size: 18,
                    color: Color(0xFF1E3A8A),
                  ),
                  label: Text(
                    l10n.privacy_policy,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInquiryTypeSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.inquiry_type,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.required,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedInquiryType == null
                  ? Colors.red
                  : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedInquiryType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: Text(
              l10n.inquiry_type_select_hint,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 20,
            ),
            items: _inquiryTypeMapping.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (_isDisposed) return;
              
              debugPrint('=== 드롭다운 선택 변경 ===');
              debugPrint('선택된 값: $newValue');
              debugPrint('선택된 값의 타입: ${newValue.runtimeType}');
              debugPrint('선택된 값의 길이: ${newValue?.length}');
              debugPrint('선택된 값의 바이트: ${newValue?.codeUnits}');
              if (newValue != null) {
                debugPrint('선택된 값의 표시 텍스트: ${_inquiryTypeMapping[newValue]}');
                debugPrint('매핑에서 해당 키가 존재하는지: ${_inquiryTypeMapping.containsKey(newValue)}');
              }
              debugPrint('현재 매핑 전체:');
              _inquiryTypeMapping.forEach((key, value) {
                debugPrint('  "$key" -> "$value"');
              });
              debugPrint('========================');
              setState(() {
                _selectedInquiryType = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.inquiry_type_required;
              }
              return null;
            },
            iconSize: 24,
            elevation: 8,
            menuMaxHeight: 200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.inquiry_title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.required,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: l10n.enter_title,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.enter_title;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.content,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.required,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _contentController,
            maxLines: 8,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: l10n.inquiry_content_hint,
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.enter_content;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageAttachmentSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.image_attachment,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.max_one_image,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectedImages.isNotEmpty ? null : _showImagePickerDialog,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: _selectedImages.isNotEmpty
                  ? Colors.grey[100]
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImages.isNotEmpty
                    ? Colors.grey[200]!
                    : Colors.grey[300]!,
              ),
            ),
            child: _selectedImages.isNotEmpty
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages.first,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedImages.isNotEmpty
                            ? Icons.check_circle
                            : Icons.add_photo_alternate,
                        color: _selectedImages.isNotEmpty
                            ? Colors.green[600]
                            : Colors.grey[600],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedImages.isEmpty
                            ? l10n.photo_attachment
                            : l10n.photo_attachment_complete,
                        style: TextStyle(
                          color: _selectedImages.isNotEmpty
                              ? Colors.green[600]
                              : Colors.grey[600],
                          fontSize: 16,
                          fontWeight: _selectedImages.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.image_selection,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.select_image_method,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 갤러리 버튼
                    _buildImageOptionButton(
                      icon: Icons.photo_library,
                      title: l10n.select_from_gallery,
                      subtitle: l10n.select_from_gallery_desc,
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(height: 12),
                    // 파일 선택 버튼
                    _buildImageOptionButton(
                      icon: Icons.folder_open,
                      title: l10n.select_from_file,
                      subtitle: l10n.select_from_file_desc,
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
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

  Widget _buildImageOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedImages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.max_one_image_error),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages = [File(image.path)];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.image_selection_error), backgroundColor: Colors.red),
      );
    }
  }

    /// 개인정보 처리방침 열기
  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://github.com/myhyun01/wsumap');
    
    try {
      // GitHub 저장소를 브라우저에서 열기
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // 외부 브라우저에서 열기
        );
      } else {
        // 링크를 열 수 없는 경우 클립보드에 복사
        await Clipboard.setData(ClipboardData(text: url.toString()));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GitHub 링크가 클립보드에 복사되었습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // 오류 발생 시 클립보드에 복사
      await Clipboard.setData(ClipboardData(text: url.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크 열기 실패. GitHub 링크가 클립보드에 복사되었습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitInquiry() async {
  if (_isDisposed) return;
  
  final l10n = AppLocalizations.of(context)!;
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_isSubmitting) return;

  setState(() {
    _isSubmitting = true;
  });

  // 로딩 다이얼로그 표시
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final category = _selectedInquiryType!; // 키 값 그대로 사용

    debugPrint('=== 문의하기 카테고리 디버그 ===');
    debugPrint('선택된 카테고리 (키 값): $category');
    debugPrint('매핑에서 해당 키가 존재하는지: ${_inquiryTypeMapping.containsKey(category)}');
    debugPrint('서버로 전송될 카테고리: $category');
    debugPrint('=== 서버 전송 데이터 ===');
    debugPrint('userId: ${widget.userAuth.userId}');
    debugPrint('category: $category');
    debugPrint('title: ${_titleController.text.trim()}');
    debugPrint('content: ${_contentController.text.trim()}');
    debugPrint('========================');

    final success = await InquiryService.createInquiry(
      userId: widget.userAuth.userId!,
      category: category, // 키 값 그대로 전송
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imageFile: _selectedImages.isNotEmpty ? _selectedImages.first : null,
    );

    if (mounted) {
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.inquiry_submit_success),
            backgroundColor: Colors.green,
          ),
        );

        // 폼 초기화
        _formKey.currentState!.reset();
        setState(() {
          _selectedInquiryType = null;
          _selectedImages.clear();
        });

        // "내 문의" 탭 새로고침
        widget.onInquirySubmitted?.call();
              } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.inquiry_submit_failed),
              backgroundColor: Colors.red,
            ),
          );
        }
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inquiry_error_occurred), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
}

// 내 문의 탭
class MyInquiriesTab extends StatefulWidget {
  final UserAuth userAuth;

  const MyInquiriesTab({required this.userAuth, super.key});

  @override
  State<MyInquiriesTab> createState() => _MyInquiriesTabState();
}

class _MyInquiriesTabState extends State<MyInquiriesTab> {
  List<InquiryItem> _inquiries = [];
  bool _isLoading = false;
  
  // 🔥 위젯 생명주기 관리
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadInquiries();
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

    Future<void> _loadInquiries() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isDisposed) return;

  setState(() {
    _isLoading = true;
  });

  try {
    debugPrint('=== 내 문의 탭에서 문의 목록 로드 시작 ===');
    debugPrint('현재 사용자 ID: ${widget.userAuth.userId}');
    debugPrint('현재 사용자 정보: ${widget.userAuth.toString()}');

    final inquiries = await InquiryService.getInquiries(
      widget.userAuth.userId!,
    );

    debugPrint('받아온 문의 개수: ${inquiries.length}');
    debugPrint(
      '받아온 문의 목록: ${inquiries.map((e) => '${e.title} (${e.status})').toList()}',
    );

    if (!_isDisposed) {
      setState(() {
        _inquiries = inquiries;
      });
      debugPrint('setState 후 _inquiries 길이: ${_inquiries.length}');
    }
  } catch (e, stackTrace) {
    debugPrint('문의 목록 로드 중 오류: $e');
    debugPrint(stackTrace.toString());
    if (!_isDisposed) {
              ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.inquiry_load_failed}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
    }
  } finally {
    if (!_isDisposed) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  // 새로고침 메서드 추가
  Future<void> refreshInquiries() async {
    await _loadInquiries();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadInquiries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _inquiries.isEmpty
            ? _buildEmptyState()
            : _buildInquiryList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                l10n.no_inquiry_history,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.no_inquiry_history_hint,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pull_to_refresh,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInquiryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _inquiries.length,
      itemBuilder: (context, index) {
        final inquiry = _inquiries[index];
        return _buildInquiryCard(inquiry);
      },
    );
  }

  Widget _buildInquiryCard(InquiryItem inquiry) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showInquiryDetail(inquiry),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            inquiry.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getLocalizedCategory(inquiry.category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(inquiry.status),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            inquiry.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getLocalizedStatus(inquiry.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(inquiry.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _showDeleteInquiryDialog(inquiry),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    inquiry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inquiry.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        inquiry.createdAt,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      if (inquiry.hasImage) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.image, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          l10n.image_attachment,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteInquiryDialog(InquiryItem inquiry) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더 - 경고 스타일
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.inquiry_delete,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.inquiry_delete_confirm,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '삭제 확인',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.inquiry_title_label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 버튼 영역
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            l10n.inquiry_delete,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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

    if (confirmed == true) {
      await _deleteInquiry(inquiry);
    }
  }

  Future<void> _deleteInquiry(InquiryItem inquiry) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      debugPrint('=== 클라이언트에서 삭제 시도 ===');
      debugPrint('문의 제목: ${inquiry.title}');
      debugPrint('문의 코드: ${inquiry.inquiryCode}');
      debugPrint('이미지 여부: ${inquiry.hasImage}');
      
      final success = await InquiryService.deleteInquiry(
        widget.userAuth.userId!,
        inquiry.inquiryCode,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.inquiry_delete_success),
            backgroundColor: Colors.green,
          ),
        );

        // 목록 새로고침
        _loadInquiries();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.inquiry_delete_failed}\n문의 코드: ${inquiry.inquiryCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 삭제 중 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.inquiry_error_occurred}\n오류: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showInquiryDetail(InquiryItem inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryDetailPage(inquiry: inquiry),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case '답변 대기':
        return Colors.orange;
      case 'answered':
      case '답변 완료':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getLocalizedStatus(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
      case '답변 대기':
        return l10n.inquiry_status_pending;
      case 'answered':
      case '답변 완료':
        return l10n.inquiry_status_answered;
      default:
        return l10n.inquiry_status_pending;
    }
  }

String _getLocalizedCategory(String category) {
  final l10n = AppLocalizations.of(context)!;
  
  // 🔥 디버깅 로그 추가
  debugPrint('=== _getLocalizedCategory 디버깅 ===');
  debugPrint('입력된 category: "$category"');
  debugPrint('category 길이: ${category.length}');
  debugPrint('category 바이트: ${category.codeUnits}');
  
  // 🔥 정규화: 공백 제거 및 소문자 변환
  final normalizedCategory = category.trim().toLowerCase();
  debugPrint('정규화된 category: "$normalizedCategory"');

  switch (normalizedCategory) {
    case 'place_error':
      debugPrint('매치됨: place_error -> ${l10n.inquiry_category_place_error}');
      return l10n.inquiry_category_place_error;
    case 'bug':
      debugPrint('매치됨: bug -> ${l10n.inquiry_category_bug}');
      return l10n.inquiry_category_bug;
    case 'feature':
      debugPrint('매치됨: feature -> ${l10n.inquiry_category_feature}');
      return l10n.inquiry_category_feature;
    case 'route_error':
      debugPrint('매치됨: route_error -> ${l10n.inquiry_category_route_error}');
      return l10n.inquiry_category_route_error;
    case 'other':
      debugPrint('매치됨: other -> ${l10n.inquiry_category_other}');
      return l10n.inquiry_category_other;
    default:
      // 🔥 매치되지 않는 경우 상세 디버깅
      debugPrint('❌ 매치되지 않음!');
      debugPrint('예상 가능한 값들과 비교:');
      debugPrint('  "place_error" == "$normalizedCategory": ${"place_error" == normalizedCategory}');
      debugPrint('  "bug" == "$normalizedCategory": ${"bug" == normalizedCategory}');
      debugPrint('  "feature" == "$normalizedCategory": ${"feature" == normalizedCategory}');
      debugPrint('  "route_error" == "$normalizedCategory": ${"route_error" == normalizedCategory}');
      debugPrint('  "other" == "$normalizedCategory": ${"other" == normalizedCategory}');
      
      // 🔥 서버에서 다른 형태로 올 가능성 체크
      if (normalizedCategory.contains('place') || normalizedCategory.contains('장소')) {
        debugPrint('장소 관련 키워드 감지 -> place_error로 처리');
        return l10n.inquiry_category_place_error;
      } else if (normalizedCategory.contains('bug') || normalizedCategory.contains('버그')) {
        debugPrint('버그 관련 키워드 감지 -> bug로 처리');
        return l10n.inquiry_category_bug;
      } else if (normalizedCategory.contains('feature') || normalizedCategory.contains('기능')) {
        debugPrint('기능 관련 키워드 감지 -> feature로 처리');
        return l10n.inquiry_category_feature;
      } else if (normalizedCategory.contains('route') || normalizedCategory.contains('경로')) {
        debugPrint('경로 관련 키워드 감지 -> route_error로 처리');
        return l10n.inquiry_category_route_error;
      }
      
      debugPrint('기본값으로 "기타" 반환');
      return l10n.inquiry_category_other; // 🔥 기본값을 "기타"로 설정
  }
}
}