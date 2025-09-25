// lib/friends/friend.dart

/// 친구 정보 모델 클래스
class Friend {
  final String userId;
  final String userName;
  final String profileImage;
  final String phone;
  final bool isLogin;
  final String lastLocation;
  final bool isLocationPublic;

  Friend({
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
}

/// 받은 친구 요청 정보 모델 클래스
class FriendRequest {
  final String fromUserId;
  final String fromUserName;
  final String createdAt;

  FriendRequest({
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
}

/// 보낸 친구 요청 정보 모델 클래스
class SentFriendRequest {
  final String toUserId;
  final String toUserName;
  final String requestDate;

  SentFriendRequest({
    required this.toUserId,
    required this.toUserName,
    required this.requestDate,
  });

  factory SentFriendRequest.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] SentFriendRequest 파싱 시도: $json');

    // 서버 명세에 따라 u."Id", u."Name" 형태로 응답이 옴
    final toUserId = _extractString(json, [
      'Id', // 서버에서 u."Id" 사용 (대문자 I)
      'id', // 소문자 버전
      'ID', // 전체 대문자 버전
      'to_user_id', // 혹시 다른 형태로 올 경우 대비
      'toUserId',
      'friend_id',
      'add_id',
    ]);

    final toUserName = _extractString(json, [
      'Name', // 서버에서 u."Name" 사용 (대문자 N)
      'name', // 소문자 버전
      'NAME', // 전체 대문자 버전
      'to_user_name', // 혹시 다른 형태로 올 경우 대비
      'toUserName',
      'friend_name',
      'add_name',
    ]);

    // 🔥 서버에서 requestDate를 반환하지 않으므로 현재 시간으로 설정
    final requestDate = _extractString(json, [
      'request_date',
      'requestDate',
      'RequestDate',
      'created_at',
      'createdAt',
      'date',
      'timestamp',
      'Date',
      'CREATED_AT',
    ]);

    // 🔥 서버에서 requestDate를 반환하지 않으므로 현재 시간으로 설정
    final finalRequestDate = requestDate.isEmpty 
        ? DateTime.now().toIso8601String() 
        : requestDate;

    print(
      '[DEBUG] 파싱 결과 - toUserId: $toUserId, toUserName: $toUserName, requestDate: $finalRequestDate',
    );

    return SentFriendRequest(
      toUserId: toUserId,
      toUserName: toUserName.isEmpty ? toUserId : toUserName,
      requestDate: finalRequestDate,
    );
  }
}

/// JSON에서 문자열 값을 안전하게 추출하는 헬퍼 함수
String _extractString(Map<String, dynamic> json, List<String> keys) {
  for (String key in keys) {
    if (json.containsKey(key)) {
      final value = json[key];
      if (value != null) {
        return value.toString().trim();
      }
    }
  }
  return '';
}

/// JSON에서 boolean 값을 안전하게 추출하는 헬퍼 함수
bool _extractBool(Map<String, dynamic> json, List<String> keys) {
  for (String key in keys) {
    if (json.containsKey(key)) {
      final value = json[key];
      if (value != null) {
        if (value is bool) return value;
        if (value is String) {
          return value.toLowerCase() == 'true' || value == '1';
        }
        if (value is int) return value == 1;
      }
    }
  }
  return false;
}

/// 위치 정보를 안전하게 추출하는 헬퍼 함수 (새로 추가)
String _extractLocation(Map<String, dynamic> json, List<String> keys) {
  for (String key in keys) {
    if (json.containsKey(key)) {
      final value = json[key];
      if (value != null) {
        // JSON 객체인 경우 처리: {"x": 36.3360047, "y": 127.4453375}
        if (value is Map<String, dynamic>) {
          final x = value['x'];
          final y = value['y'];
          if (x != null && y != null) {
            // 표준 JSON 형태로 변환
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
  }
  return '';
}
