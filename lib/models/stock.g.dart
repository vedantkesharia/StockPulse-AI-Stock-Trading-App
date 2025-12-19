part of 'stock.dart';

Stock _$StockFromJson(Map<String, dynamic> json) => Stock(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$StockToJson(Stock instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'description': instance.description,
    };

StockData _$StockDataFromJson(Map<String, dynamic> json) => StockData(
      timestamp: json['timestamp'] as String,
      price: (json['price'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      open: (json['open'] as num?)?.toDouble(),
      close: (json['close'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StockDataToJson(StockData instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'price': instance.price,
      'volume': instance.volume,
      'high': instance.high,
      'low': instance.low,
      'open': instance.open,
      'close': instance.close,
    };

MarketStats _$MarketStatsFromJson(Map<String, dynamic> json) => MarketStats(
      currentPrice: (json['currentPrice'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      dayHigh: (json['dayHigh'] as num).toDouble(),
      dayLow: (json['dayLow'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      avgVolume: (json['avgVolume'] as num).toDouble(),
    );

Map<String, dynamic> _$MarketStatsToJson(MarketStats instance) => <String, dynamic>{
      'currentPrice': instance.currentPrice,
      'changePercent': instance.changePercent,
      'changeAmount': instance.changeAmount,
      'dayHigh': instance.dayHigh,
      'dayLow': instance.dayLow,
      'volume': instance.volume,
      'avgVolume': instance.avgVolume,
    };

