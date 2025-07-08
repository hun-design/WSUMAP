import 'package:flutter/material.dart';

// --------------------------------------------------
// 1. 데이터 구조(모델) 정의
// --------------------------------------------------
class NavNode {
  final String id;
  final Offset position;
  NavNode({required this.id, required this.position});
}

class WeightedEdge {
  final String nodeId;
  final double weight;
  WeightedEdge({required this.nodeId, required this.weight});
}

// --------------------------------------------------
// 2. 길찾기 그래프 원본 데이터
// --------------------------------------------------

// --- (1층) Floor_Id = 3 에 해당하는 노드 연결 정보 ---
final Map<String, List<String>> floor3AdjacencyList = {
  '101': ['b1'], '102': ['b2'], '103': ['b3'], '104': ['b3'], '105': ['b3'],
  '106': ['b3'], '107': ['b9'], '108': ['b9'], '109': ['b9'], '110': ['b8', 'b9'],
  '111': ['b7'], '112': ['b6'],
  
  'b1': ['101', 'b2', 'b4'], 'b2': ['102', 'b1', 'b3'], 'b3': ['103', '104', '105', '106', 'b2'],
  'b4': ['b1', 'b10', 'b5'], 'b5': ['b4', 'b11', 'b6'], 'b6': ['112', 'b5', 'b7'],
  'b7': ['111', 'b6', 'b8'], 'b8': ['110', 'b7', 'b9'], 'b9': ['107', '108', '109', '110', 'b8'],
  'b10': ['b4', 'enterence'], 'b11': ['b5', 'indoor-left-stairs', 'indoor-right-stairs'],
  
  'enterence': ['b10', 'outdoor-left-stairs', 'outdoor-right-stairs'],
  
  // ★★★ [수정] 1층 계단에 2층으로 가는 가상 연결점을 추가합니다. ★★★
  // 길찾기 알고리즘이 이 특별한 ID를 보고 층간 이동을 인지하게 됩니다.
  'indoor-left-stairs': ['b11', '5_indoor-left-stairs'], 
  'indoor-right-stairs': ['b11', '5_indoor-right-stairs'],
  'outdoor-left-stairs': ['enterence', '5_outdoor-left-stairs'],
  'outdoor-right-stairs': ['enterence', '5_outdoor-right-stairs'],
};

// --- (2층) Floor_Id = 5 에 해당하는 노드 연결 정보 ---
final Map<String, List<String>> floor5AdjacencyList = {
  '201': ['b28'], '202': ['b26'], '203': ['b26'], '204': ['b25'], '205': ['b25'],
  '206': ['b24'], '207': ['b24'], '208': ['b23'], '209': ['b23'], '210': ['b22'],
  '211': ['b22'], '212': ['b21'], '213': ['b21'], '214': ['b20'], '215': ['b18'],
  '216': ['b17'], '217': ['b16'], '218': ['b10', 'b11'], '219': ['b10'], '220': ['b9'],
  '221': ['b7'], '222': ['b7'], '223': ['b6'], '224': ['b6'], '225': ['b5'],
  '226': ['b5'], '227': ['b4'], '228': ['b4'], '229': ['b3'], '230': ['b3'],
  '231': ['b2'], '232': ['b2'], '233': ['b1'],
  
  'b1': ['233', 'b2', 'indoor-right-stairs'], 'b2': ['231', '232', 'b1', 'b3'],
  'b3': ['229', '230', 'b2', 'b4'], 'b4': ['227', '228', 'b3', 'b5'],
  'b5': ['225', '226', 'b4', 'b6'], 'b6': ['223', '224', 'b5', 'b7'],
  'b7': ['221', '222', 'b6', 'b8'], 'b8': ['b10', 'b7', 'b9'], 'b9': ['220', 'b8'],
  'b10': ['218', '219', 'b8'], 'b11': ['218', 'b12', 'b14', 'b16'], 'b12': ['b11', 'b13'],
  'b13': ['b12', 'outdoor-right-stairs'], 'b14': ['b11', 'b15'], 'b15': ['b14', 'outdoor-left-stairs'],
  'b16': ['217', 'b11', 'b17'], 'b17': ['216', 'b16', 'b18'], 'b18': ['215', 'b17', 'b19'],
  'b19': ['214', 'b18', 'b20', 'b21'], 'b20': ['214', 'b19'],
  'b21': ['212', '213', 'b19', 'b22'], 'b22': ['210', '211', 'b21', 'b23'],
  'b23': ['208', '209', 'b22', 'b24'], 'b24': ['206', '207', 'b23', 'b25'],
  'b25': ['204', '205', 'b24', 'b26'], 'b26': ['202', '203', 'b25', 'b27'],
  'b27': ['b26', 'b28'], 'b28': ['201', 'b27', 'indoor-left-stairs'],

  // ★★★ [수정] 2층 계단에 1층으로 가는 가상 연결점을 추가합니다. ★★★
  'indoor-left-stairs': ['b28', '3_indoor-left-stairs'],
  'indoor-right-stairs': ['b1', '3_indoor-right-stairs'],
  'outdoor-left-stairs': ['b15', '3_outdoor-left-stairs'],
  'outdoor-right-stairs': ['b13', '3_outdoor-right-stairs'],
};
