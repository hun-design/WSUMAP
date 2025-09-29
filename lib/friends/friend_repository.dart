// lib/friends/friend_repository.dart
import 'friend_api_service.dart';
import 'friend.dart';

class FriendRepository {
  final FriendApiService apiService;
  FriendRepository(this.apiService);

  Future<List<Friend>> getMyFriends() =>
      apiService.fetchMyFriends();
  Future<void> requestFriend(String addId) async {
    print('[DEBUG] 🔄 Repository.requestFriend 시작: addId=$addId');
    try {
      await apiService.addFriend(addId);
      print('[DEBUG] ✅ Repository.requestFriend 성공');
    } catch (e) {
      print('[DEBUG] ❌ Repository.requestFriend 실패: $e');
      rethrow;
    }
  }
  Future<List<FriendRequest>> getFriendRequests() =>
      apiService.fetchFriendRequests();
  Future<void> acceptRequest(String addId) =>
      apiService.acceptFriendRequest(addId);
  Future<void> rejectRequest(String addId) =>
      apiService.rejectFriendRequest(addId);
  Future<void> deleteFriend(String addId) =>
      apiService.deleteFriend(addId);
  Future<Friend?> getFriendInfo(String friendId) async {
    return await apiService.fetchFriendInfo(friendId);
  }

  /// 내가 보낸 친구 요청 목록 조회
  Future<List<SentFriendRequest>> getSentFriendRequests() =>
      apiService.fetchSentFriendRequests();

  /// 보낸 친구 요청 취소
  Future<void> cancelSentRequest(String friendId) =>
      apiService.cancelSentFriendRequest(friendId);

  /// 🔥 친구 상태 새로고침 (서버의 /myfriend API 사용)
  Future<List<Friend>> refreshFriendStatus() async {
    print('[DEBUG] 🔄 친구 상태 새로고침 시작');
    try {
      // /myfriend API를 사용하여 최신 친구 상태 조회
      final friends = await apiService.fetchMyFriends();
      print('[DEBUG] ✅ 친구 상태 새로고침 완료: ${friends.length}명');
      return friends;
    } catch (e) {
      print('[ERROR] ❌ 친구 상태 새로고침 실패: $e');
      rethrow;
    }
  }
}
