// lib/models/item.dart
import 'package:flutter/foundation.dart';

@immutable
class Item {
  final String id;
  final String name;
  final int currentPrice;
  final int? previousPrice;
  final DateTime updatedAt;
  final bool isPinned;
  final int sortOrder;

  const Item({
    required this.id,
    required this.name,
    required this.currentPrice,
    this.previousPrice,
    required this.updatedAt,
    this.isPinned = false,
    required this.sortOrder,
  });

  /// 価格差分（現在 - 前回）
  /// 前回価格がない場合はnull
  int? get priceDiff {
    if (previousPrice == null) return null;
    return currentPrice - previousPrice!;
  }

  /// 価格が上がったか
  bool get isPriceUp => (priceDiff ?? 0) > 0;

  /// 価格が下がったか
  bool get isPriceDown => (priceDiff ?? 0) < 0;

  /// 価格が変わらないか
  bool get isPriceSame => priceDiff == 0;

  Item copyWith({
    String? id,
    String? name,
    int? currentPrice,
    int? previousPrice,
    DateTime? updatedAt,
    bool? isPinned,
    int? sortOrder,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// 価格を更新したItemを返す
  /// 現在の価格が前回価格になり、新しい価格が現在価格になる
  Item updatePrice(int newPrice) {
    return Item(
      id: id,
      name: name,
      currentPrice: newPrice,
      previousPrice: currentPrice,
      updatedAt: DateTime.now(),
      isPinned: isPinned,
      sortOrder: sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'sortOrder': sortOrder,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      currentPrice: json['currentPrice'] as int,
      previousPrice: json['previousPrice'] as int?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: (json['isPinned'] as int) == 1,
      sortOrder: json['sortOrder'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
