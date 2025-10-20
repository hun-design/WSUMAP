// lib/friends/friend_repository.dart - 최적화된 버전

import 'friend_api_service.dart';
import 'friend.dart';

/// 친구 데이터 레포지토리
class FriendRepository {
  final FriendApiService apiService;
  
  FriendRepository(this.apiService);

  /// 내 친구 목록 조회
  Future<List<Friend>> getMyFriends() => apiService.fetchMyFriends();

  /// 친구 추가 요청
  Future<void> requestFriend(String addId) async {
    await apiService.addFriend(addId);
  }

  /// 받은 친구 요청 목록 조회
  Future<List<FriendRequest>> getFriendRequests() => apiService.fetchFriendRequests();

  /// 친구 요청 수락
  Future<void> acceptRequest(String addId) => apiService.acceptFriendRequest(addId);

  /// 친구 요청 거절
  Future<void> rejectRequest(String addId) => apiService.rejectFriendRequest(addId);

  /// 친구 삭제
  Future<void> deleteFriend(String addId) => apiService.deleteFriend(addId);

  /// 보낸 친구 요청 목록 조회
  Future<List<SentFriendRequest>> getSentFriendRequests() => apiService.fetchSentFriendRequests();

  /// 보낸 친구 요청 취소
  Future<void> cancelSentRequest(String friendId) => apiService.cancelSentFriendRequest(friendId);

  /// 친구 상태 새로고침 (서버의 /myfriend API 사용)
  Future<List<Friend>> refreshFriendStatus() async {
    return await apiService.fetchMyFriends();
  }
}
