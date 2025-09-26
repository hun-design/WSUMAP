// lib/friends/friend_exceptions.dart - 친구 관련 예외 클래스들

/// 존재하지 않는 사용자 예외
class UserNotFoundException implements Exception {
  final String message;
  final String userId;
  
  UserNotFoundException(this.userId) : message = '존재하지 않는 사용자입니다';
  
  @override
  String toString() => message;
}

/// 이미 친구인 사용자 예외
class AlreadyFriendException implements Exception {
  final String message;
  final String userId;
  
  AlreadyFriendException(this.userId) : message = '이미 친구인 사용자입니다';
  
  @override
  String toString() => message;
}

/// 이미 요청을 보낸 사용자 예외
class AlreadyRequestedException implements Exception {
  final String message;
  final String userId;
  
  AlreadyRequestedException(this.userId) : message = '이미 친구 요청을 보낸 사용자입니다';
  
  @override
  String toString() => message;
}

/// 자기 자신을 친구로 추가하려는 예외
class SelfFriendException implements Exception {
  final String message;
  
  SelfFriendException() : message = '자기 자신을 친구로 추가할 수 없습니다';
  
  @override
  String toString() => message;
}

/// 잘못된 사용자 ID 예외
class InvalidUserIdException implements Exception {
  final String message;
  final String userId;
  
  InvalidUserIdException(this.userId) : message = '잘못된 사용자 ID입니다';
  
  @override
  String toString() => message;
}

/// 서버 오류 예외
class ServerErrorException implements Exception {
  final String message;
  
  ServerErrorException() : message = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
  
  @override
  String toString() => message;
}

/// 친구 관련 예외 처리 유틸리티
class FriendExceptionHandler {
  /// 예외를 분석하여 적절한 예외 객체를 반환
  static Exception analyzeException(dynamic error, String userId) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('존재하지 않는') || 
        errorString.contains('not found') || 
        errorString.contains('user not found') ||
        errorString.contains('404')) {
      return UserNotFoundException(userId);
    } else if (errorString.contains('이미 친구') || 
               errorString.contains('already friend')) {
      return AlreadyFriendException(userId);
    } else if (errorString.contains('이미 요청') || 
               errorString.contains('already requested')) {
      return AlreadyRequestedException(userId);
    } else if (errorString.contains('자기 자신') || 
               errorString.contains('self')) {
      return SelfFriendException();
    } else if (errorString.contains('invalid') || 
               errorString.contains('잘못된')) {
      return InvalidUserIdException(userId);
    } else if (errorString.contains('서버 오류') || 
               errorString.contains('server error') ||
               errorString.contains('500')) {
      return ServerErrorException();
    } else {
      return Exception(error.toString());
    }
  }
  
  /// 예외 타입 확인
  static bool isUserNotFound(Exception exception) {
    return exception is UserNotFoundException;
  }
  
  static bool isAlreadyFriend(Exception exception) {
    return exception is AlreadyFriendException;
  }
  
  static bool isAlreadyRequested(Exception exception) {
    return exception is AlreadyRequestedException;
  }
  
  static bool isSelfFriend(Exception exception) {
    return exception is SelfFriendException;
  }
  
  static bool isInvalidUserId(Exception exception) {
    return exception is InvalidUserIdException;
  }
  
  static bool isServerError(Exception exception) {
    return exception is ServerErrorException;
  }
}
