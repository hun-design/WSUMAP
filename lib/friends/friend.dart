// lib/friends/friend.dart - 최적화된 버전

/// 친구 정보 모델 클래스
class Friend {
  final String userId;
  final String userName;
  final String profileImage;
  final String phone;
  final bool isLogin;
  final String lastLocation;
  final bool isLocationPublic;

  const Friend({
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.phone,
    required this.isLogin,
    required this.lastLocation,
    required this.isLocationPublic,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: _extractString(json, ['Id', 'user_id', 'id', 'userId']),
      userName: _extractString(json, ['Name', 'user_name', 'name', 'userName']),
      profileImage: _extractString(json, [
        'profile_image',
        'profileImage',
        'Profile_Image',
      ]),
      phone: _extractString(json, ['Phone', 'phone', 'phoneNumber']),
      isLogin: _extractBool(json, [
        'Is_Login',
        'islogin',
        'is_login',
        'isLogin',
        'online',
        'Online',
      ]),
      lastLocation: _extractLocation(json, [
        'Last_Location',
        'last_location',
        'lastLocation',
        'location',
      ]),
      isLocationPublic: _extractBool(json, [
        'Is_location_public',
        'isLocationPublic',
        'locationPublic',
        'is_location_public',
        'location_public',
        'is_locationPublic',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'profileImage': profileImage,
      'phone': phone,
      'isLogin': isLogin,
      'lastLocation': lastLocation,
      'isLocationPublic': isLocationPublic,
    };
  }

  /// copyWith 메서드 추가 (불변성 유지)
  Friend copyWith({
    String? userId,
    String? userName,
    String? profileImage,
    String? phone,
    bool? isLogin,
    String? lastLocation,
    bool? isLocationPublic,
  }) {
    return Friend(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      isLogin: isLogin ?? this.isLogin,
      lastLocation: lastLocation ?? this.lastLocation,
      isLocationPublic: isLocationPublic ?? this.isLocationPublic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Friend &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          userName == other.userName &&
          isLogin == other.isLogin;

  @override
  int get hashCode => userId.hashCode ^ userName.hashCode ^ isLogin.hashCode;

  @override
  String toString() {
    return 'Friend(userId: $userId, userName: $userName, isLogin: $isLogin)';
  }
}

/// 받은 친구 요청 정보 모델 클래스
class FriendRequest {
  final String fromUserId;
  final String fromUserName;
  final String createdAt;

  const FriendRequest({
    required this.fromUserId, 
    required this.fromUserName,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      fromUserId: _extractString(json, [
        'from_user_id',
        'Id',
        'id',
        'fromUserId',
        'from_id',
      ]),
      fromUserName: _extractString(json, [
        'from_user_name',
        'Name',
        'name',
        'fromUserName',
        'from_name',
      ]),
      createdAt: _extractString(json, [
        'created_at',
        'createdAt',
        'request_date',
        'requestDate',
        'date',
        'timestamp',
      ]).isEmpty ? DateTime.now().toIso8601String() : _extractString(json, [
        'created_at',
        'createdAt',
        'request_date',
        'requestDate',
        'date',
        'timestamp',
      ]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequest &&
          runtimeType == other.runtimeType &&
          fromUserId == other.fromUserId;

  @override
  int get hashCode => fromUserId.hashCode;

  @override
  String toString() {
    return 'FriendRequest(fromUserId: $fromUserId, fromUserName: $fromUserName)';
  }
}

/// 보낸 친구 요청 정보 모델 클래스
class SentFriendRequest {
  final String toUserId;
  final String toUserName;
  final String requestDate;

  const SentFriendRequest({
    required this.toUserId,
    required this.toUserName,
    required this.requestDate,
  });

  factory SentFriendRequest.fromJson(Map<String, dynamic> json) {
    final toUserId = _extractString(json, [
      'Id', 'id', 'ID', 'to_user_id', 'toUserId', 'friend_id', 'add_id',
    ]);

    final toUserName = _extractString(json, [
      'Name', 'name', 'NAME', 'to_user_name', 'toUserName', 'friend_name', 'add_name',
    ]);

    final requestDate = _extractString(json, [
      'request_date', 'requestDate', 'RequestDate', 'created_at', 'createdAt', 'date', 'timestamp', 'Date', 'CREATED_AT',
    ]);

    final finalRequestDate = requestDate.isEmpty ? DateTime.now().toIso8601String() : requestDate;

    return SentFriendRequest(
      toUserId: toUserId,
      toUserName: toUserName.isEmpty ? toUserId : toUserName,
      requestDate: finalRequestDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentFriendRequest &&
          runtimeType == other.runtimeType &&
          toUserId == other.toUserId;

  @override
  int get hashCode => toUserId.hashCode;

  @override
  String toString() {
    return 'SentFriendRequest(toUserId: $toUserId, toUserName: $toUserName)';
  }
}

/// 🔥 JSON 헬퍼 함수들 (최적화)

/// JSON에서 문자열 값을 안전하게 추출
String _extractString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString().trim();
    }
  }
  return '';
}

/// JSON에서 boolean 값을 안전하게 추출
bool _extractBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      if (value is int) return value == 1;
    }
  }
  return false;
}

/// 위치 정보를 안전하게 추출
String _extractLocation(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      // JSON 객체인 경우 처리: {"x": 36.3360047, "y": 127.4453375}
      if (value is Map<String, dynamic>) {
        final x = value['x'];
        final y = value['y'];
        if (x != null && y != null) {
          return '{x: $x, y: $y}';
        }
      }
      // 문자열인 경우 그대로 반환
      else if (value is String) {
        return value.trim();
      }
      // 기타 타입은 문자열로 변환
      else {
        return value.toString().trim();
      }
    }
  }
  return '';
}
