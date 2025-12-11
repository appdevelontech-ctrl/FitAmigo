import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/friends_model.dart';

import '../services/api_service.dart';

class FriendController extends GetxController {
  final ApiService _apiService = ApiService();

  var activeChatUserId = "".obs;

  /// Loading States
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// User
  String currentUserId = "";

  var friends = <Friend>[].obs;
  var friendRequests = <dynamic>[].obs;
  var searchResults = <Friend>[].obs;

  /// Dynamic State + City (from API)
  var stateList = <String>[].obs;
  var cityList = <String>[].obs;

  /// Filters
  var swipeList = <Friend>[].obs;

  var selectedState = "".obs;
  var selectedCity = "".obs;

  /// Departments
  var departmentList = <DepartmentModel>[].obs;
  var selectedDepartmentId = "".obs;

  /// Sub Departments
  var subDepartmentList = <String>[].obs;
  var selectedSubDept = "".obs;

  /// Distance
  var selectedDistance = "5".obs;

  var currentPage = 1.obs;

  /// GPS
  var userLat = "".obs;
  var userLng = "".obs;
  var useGpsLocation = false.obs;

  /// Chat Cache
  var lastMessages = <String, String>{}.obs;
  var unreadCountPerUser = <String, int>{}.obs;
  var totalUnread = 0.obs;

  IO.Socket? socket;

  @override
  void onInit() {
    super.onInit();

    loadLocations();   // Load state + city dynamically
    _loadUserId().then((_) {
      _initSocket();
      fetchAllData();
      loadDepartments();

      /// Default: select first state/city
      if (stateList.isNotEmpty) selectedState.value = stateList.first;
      if (cityList.isNotEmpty) selectedCity.value = cityList.first;

      loadFilteredFriends(reset: true);
    });
  }

  /// ================================
  /// 🌍 Set User GPS Location
  /// ================================
  Future<void> setUserLocation(double lat, double lng) async {
    userLat.value = lat.toString();
    userLng.value = lng.toString();
    useGpsLocation.value = true;


    print("📍 GPS Mode Activated → lat:$lat lng:$lng");

    loadFilteredFriends(reset: true);
  }

  /// ================================
  /// 🌍 Load State & City From API
  /// ================================
  Future<void> loadLocations() async {
    try {
      final res = await _apiService.getAllZones();

      stateList.assignAll(res.uniqueLocations);
      cityList.assignAll(res.uniqueLocations);

      print("🌍 States Loaded: $stateList");
      print("🏙 Cities Loaded: $cityList");

      /// Default selection
      if (stateList.isNotEmpty) selectedState.value = stateList.first;
      if (cityList.isNotEmpty) selectedCity.value = cityList.first;

    } catch (e) {
      print("❌ Error loading locations: $e");
    }
  }

  /// ================================
  ///  USER ID
  /// ================================
  Future<void> _loadUserId() async {
    currentUserId = await _apiService.getUserId();
  }

  /// ================================
  ///  LOAD DEPARTMENTS
  /// ================================
  Future<void> loadDepartments() async {
    final list = await _apiService.getAllDepartments();
    departmentList.assignAll(list);
  }

  /// ================================
  ///  LOAD SUB-DEPARTMENTS
  /// ================================
  void loadSubDepartments(String deptId) {
    final dept = departmentList.firstWhere((d) => d.id == deptId);
    subDepartmentList.assignAll(dept.values);
  }

  /// ================================
  ///  FILTER FRIENDS (GPS + DROPDOWN BOTH)
  /// ================================
  Future<void> loadFilteredFriends({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      swipeList.clear();
    }

    try {
      isLoading.value = true;

      final response = await _apiService.getFilteredFriends(
        state: useGpsLocation.value ? "Delhi" : selectedState.value,  // 👈 FIX
        city: useGpsLocation.value ? "Delhi" : selectedCity.value,     // 👈 FIX
        department: selectedDepartmentId.value,
        subDepartment: selectedSubDept.value,
        page: currentPage.value,
        distance: selectedDistance.value,
        lat: useGpsLocation.value ? userLat.value : null,
        lng: useGpsLocation.value ? userLng.value : null,
      );


      if (response.success) {
        swipeList.addAll(response.friends);

        /// If API sends updated dropdown data
        if (response.departments.isNotEmpty) {
          departmentList.assignAll(response.departments);
        }

        if (response.subDepartments.isNotEmpty) {
          subDepartmentList.assignAll(response.subDepartments);
        }

        currentPage.value++;
      }

    } catch (e) {
      print("❌ FilterError: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================================
  /// SEARCH FRIENDS
  /// ================================
  Future<void> findAllFriends(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.findAllFriends(query);

      if (response.success) searchResults.assignAll(response.friends);

    } finally {
      isLoading.value = false;
    }
  }

  /// ================================
  /// LOAD FRIENDS + REQUESTS
  /// ================================
  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;

      final fRes = await _apiService.getFriends();
      if (fRes.success) friends.assignAll(fRes.friends);

      final rRes = await _apiService.getFriendRequests();
      if (rRes.success) friendRequests.assignAll(rRes.requests);

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// ================================
  /// SOCKET
  /// ================================
  void _initSocket() {
    socket = IO.io(
      'wss://dharma-back-dbxy.onrender.com/',
      IO.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    socket?.connect();

    socket?.on('chat message', (data) {
      if (data == null) return;

      final senderId = data['senderId'];
      final text = data['text'] ?? "";

      // Always update last message
      lastMessages[senderId] = text;
      lastMessages.refresh();

      // 🔥 Check if user is inside chat with this exact friend
      bool isChattingWithSameUser = activeChatUserId.value == senderId;

      if (!isChattingWithSameUser && senderId != currentUserId) {
        // Increase unread count ONLY when user is NOT chatting with sender
        unreadCountPerUser[senderId] = (unreadCountPerUser[senderId] ?? 0) + 1;
        unreadCountPerUser.refresh();

        // Update total unread
        totalUnread.value = unreadCountPerUser.values.fold(0, (sum, e) => sum + e);
      }

      update();
    });


  }

  /// ================================
  /// REQUEST ACTIONS
  /// ================================
  Future<void> sendFriendRequest(String receiverId) async {
    await _apiService.sendFriendRequest(receiverId);
    Get.snackbar("✔ Sent", "Friend request sent!");
  }

  Future<void> acceptFriendRequest(String senderId) async {
    await _apiService.acceptFriendRequest(senderId);
    Get.snackbar("🎉 Success", "Friend Added!");
    fetchAllData();
  }

  void clearUnread(String id) {
    unreadCountPerUser.remove(id);
    totalUnread.value =
        unreadCountPerUser.values.fold(0, (sum, e) => sum + e);
    lastMessages.remove(id);
    update();
  }
}
