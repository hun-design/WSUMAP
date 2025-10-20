// lib/friends/friend_exceptions.dart - 최적화된 버전

/// 존재하지 않는 사용자 예외
class UserNotFoundException implements Exception {
  final String message;
  final String userId;
  
  const UserNotFoundException(this.userId) : message = '존재하지 않는 사용자입니다';
  
  @override
  String toString() => message;
}

/// 이미 친구인 사용자 예외
class AlreadyFriendException implements Exception {
  final String message;
  final String userId;
  
  const AlreadyFriendException(this.userId) : message = '이미 친구인 사용자입니다';
  
  @override
  String toString() => message;
}

/// 이미 요청을 보낸 사용자 예외
class AlreadyRequestedException implements Exception {
  final String message;
  final String userId;
  
  const AlreadyRequestedException(this.userId) : message = '이미 친구 요청을 보낸 사용자입니다';
  
  @override
  String toString() => message;
}

/// 자기 자신을 친구로 추가하려는 예외
class SelfFriendException implements Exception {
  final String message;
  
  const SelfFriendException() : message = '자기 자신을 친구로 추가할 수 없습니다';
  
  @override
  String toString() => message;
}

/// 잘못된 사용자 ID 예외
class InvalidUserIdException implements Exception {
  final String message;
  final String userId;
  
  const InvalidUserIdException(this.userId) : message = '잘못된 사용자 ID입니다';
  
  @override
  String toString() => message;
}

/// 서버 오류 예외
class ServerErrorException implements Exception {
  final String message;
  
  const ServerErrorException() : message = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
  
  @override
  String toString() => message;
}

/// 🔥 친구 관련 예외 처리 유틸리티 (최적화)
class FriendExceptionHandler {
  
  /// 예외를 분석하여 적절한 예외 객체를 반환
  static Exception analyzeException(dynamic error, String userId) {
    final errorString = error.toString().toLowerCase();
    
    if (_containsAny(errorString, ['존재하지 않는', 'not found', 'user not found', '404'])) {
      return UserNotFoundException(userId);
    } else if (_containsAny(errorString, ['이미 친구', 'already friend'])) {
      return AlreadyFriendException(userId);
    } else if (_containsAny(errorString, ['이미 요청', 'already requested'])) {
      return AlreadyRequestedException(userId);
    } else if (_containsAny(errorString, ['자기 자신', 'self'])) {
      return SelfFriendException();
    } else if (_containsAny(errorString, ['invalid', '잘못된'])) {
      return InvalidUserIdException(userId);
    } else if (_containsAny(errorString, ['서버 오류', 'server error', '500'])) {
      return ServerErrorException();
    } else {
      return Exception(error.toString());
    }
  }
  
  /// 여러 문자열 중 하나라도 포함되어 있는지 확인
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
  
  /// 예외 타입 확인
  static bool isUserNotFound(Exception exception) => exception is UserNotFoundException;
  static bool isAlreadyFriend(Exception exception) => exception is AlreadyFriendException;
  static bool isAlreadyRequested(Exception exception) => exception is AlreadyRequestedException;
  static bool isSelfFriend(Exception exception) => exception is SelfFriendException;
  static bool isInvalidUserId(Exception exception) => exception is InvalidUserIdException;
  static bool isServerError(Exception exception) => exception is ServerErrorException;
}
