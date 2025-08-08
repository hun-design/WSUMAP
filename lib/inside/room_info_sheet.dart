import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';
import 'room_info.dart';

class RoomInfoSheet extends StatelessWidget {
  final RoomInfo roomInfo;
  final VoidCallback? onDeparture;
  final VoidCallback? onArrival;
  final String? buildingName;
  final dynamic floorNumber;

  const RoomInfoSheet({
    Key? key,
    required this.roomInfo,
    this.onDeparture,
    this.onArrival,
    this.buildingName,
    this.floorNumber,
  }) : super(key: key);

  void _handlePhone(BuildContext context, String phone) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(AppLocalizations.of(context)!.errorCannotOpenPhoneApp)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _handleEmail(BuildContext context, String email) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: email));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(AppLocalizations.of(context)!.emailCopied)),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // 🔥 친구창과 동일한 상세 정보 행 위젯
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isClickable ? Colors.blueAccent : const Color(0xFF1E3A8A),
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 상단 드래그 핸들
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 🔥 헤더 - 친구창과 동일한 스타일 + 오른쪽 상단 닫기 버튼
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.meeting_room,
                    color: Color(0xFF1E3A8A),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${roomInfo.name}호',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${buildingName ?? ''} ${floorNumber != null ? '${floorNumber}층' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF1E3A8A).withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 🔥 오른쪽 상단 닫기 버튼
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF1E3A8A),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // 🔥 내용 - 친구창과 동일한 간격과 스타일
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 설명
                if (roomInfo.desc.trim().isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.description,
                    loc!.description,
                    roomInfo.desc.trim(),
                  ),
                  const SizedBox(height: 16),
                ],

                // 담당자
                if (roomInfo.users.where((u) => u.trim().isNotEmpty).isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.person,
                    loc!.personInCharge,
                    roomInfo.users.where((u) => u.trim().isNotEmpty).map((u) => u.trim()).join(", "),
                  ),
                  const SizedBox(height: 16),
                ],

                // 전화번호들
                if (roomInfo.phones != null)
                  ...roomInfo.phones!
                      .where((p) => p.trim().isNotEmpty)
                      .map((p) => p.trim())
                      .map(
                        (phone) => Column(
                          children: [
                            _buildDetailRow(
                              Icons.phone,
                              loc!.contact,
                              phone,
                              isClickable: true,
                              onTap: () => _handlePhone(context, phone),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                // 이메일들
                if (roomInfo.emails != null)
                  ...roomInfo.emails!
                      .where((e) => e.trim().isNotEmpty)
                      .map((e) => e.trim())
                      .map(
                        (email) => Column(
                          children: [
                            _buildDetailRow(
                              Icons.email,
                              loc!.email,
                              email,
                              isClickable: true,
                              onTap: () => _handleEmail(context, email),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                // 정보가 없는 경우
                if (roomInfo.desc.trim().isEmpty &&
                    roomInfo.users.where((u) => u.trim().isNotEmpty).isEmpty &&
                    (roomInfo.phones == null || roomInfo.phones!.where((p) => p.trim().isNotEmpty).isEmpty) &&
                    (roomInfo.emails == null || roomInfo.emails!.where((e) => e.trim().isNotEmpty).isEmpty)) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loc!.noDetailedInfoRegistered,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // 🔥 버튼 영역 - 길찾기 버튼들만
          if (onDeparture != null || onArrival != null)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Row(
                children: [
                  if (onDeparture != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          try {
                            final roomData = {
                              'roomId': roomInfo.id,
                              'roomName': roomInfo.name,
                              'buildingName': buildingName ?? '',
                              'floorNumber': floorNumber?.toString() ?? '',
                              'type': 'start',
                            };
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/directions',
                              arguments: roomData,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child:
                                            Text(loc!.errorOccurred(e.toString()))),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF1E3A8A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        label: Text(
                          loc!.setDeparture,
                          style: const TextStyle(color: Color(0xFF1E3A8A)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.white),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],

                  if (onDeparture != null && onArrival != null)
                    const SizedBox(width: 12),

                  if (onArrival != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          try {
                            final roomData = {
                              'roomId': roomInfo.id,
                              'roomName': roomInfo.name,
                              'buildingName': buildingName ?? '',
                              'floorNumber': floorNumber?.toString() ?? '',
                              'type': 'end',
                            };
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/directions',
                              arguments: roomData,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child:
                                            Text(loc!.errorOccurred(e.toString()))),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        label: Text(
                          loc!.setArrival,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // 🔥 하단 안전 영역 (버튼이 없을 때만)
          if (onDeparture == null && onArrival == null)
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24)
          else
            SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
