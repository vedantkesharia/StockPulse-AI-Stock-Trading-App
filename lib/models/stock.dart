import 'package:json_annotation/json_annotation.dart';

part 'stock.g.dart';

@JsonSerializable()
class Stock {
  final String symbol;
  final String name;
  final String? description;
  
  Stock({
    required this.symbol,
    required this.name,
    this.description,
  });
  
  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);
}

@JsonSerializable()
class StockData {
  final String timestamp;
  final double price;
  final double volume;
  final double? high;
  final double? low;
  final double? open;
  final double? close;
  
  StockData({
    required this.timestamp,
    required this.price,
    required this.volume,
    this.high,
    this.low,
    this.open,
    this.close,
  });
  
  factory StockData.fromJson(Map<String, dynamic> json) => _$StockDataFromJson(json);
  Map<String, dynamic> toJson() => _$StockDataToJson(this);
}

@JsonSerializable()
class MarketStats {
  final double currentPrice;
  final double changePercent;
  final double changeAmount;
  final double dayHigh;
  final double dayLow;
  final double volume;
  final double avgVolume;
  
  MarketStats({
    required this.currentPrice,
    required this.changePercent,
    required this.changeAmount,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    required this.avgVolume,
  });
  
  factory MarketStats.fromJson(Map<String, dynamic> json) => _$MarketStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MarketStatsToJson(this);
}
