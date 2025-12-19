import 'dart:math';
import '../models/stock.dart';

class MockDataGenerator {
  static final Random _random = Random();
  
  static final Map<String, double> _basePrices = {
    'AAPL': 180.0,
    'GOOGL': 140.0,
    'MSFT': 380.0,
    'TSLA': 240.0,
    'AMZN': 150.0,
    'NVDA': 480.0,
    'META': 320.0,
  };
  
  // Generate realistic stock price data
  static List<StockData> generateStockData(String symbol, int days) {
    final basePrice = _basePrices[symbol] ?? 100.0;
    final data = <StockData>[];
    double price = basePrice;
    
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      
      // Simulate realistic price movement
      final volatility = basePrice * 0.02; // 2% volatility
      final change = (_random.nextDouble() - 0.48) * volatility;
      price = (price + change).clamp(basePrice * 0.7, basePrice * 1.3);
      
      final open = price + (_random.nextDouble() - 0.5) * volatility * 0.5;
      final high = max(price, open) + _random.nextDouble() * volatility * 0.3;
      final low = min(price, open) - _random.nextDouble() * volatility * 0.3;
      final close = price;
      
      data.add(StockData(
        timestamp: date.toIso8601String(),
        price: double.parse(close.toStringAsFixed(2)),
        volume: (_random.nextDouble() * 50000000 + 10000000),
        high: double.parse(high.toStringAsFixed(2)),
        low: double.parse(low.toStringAsFixed(2)),
        open: double.parse(open.toStringAsFixed(2)),
        close: double.parse(close.toStringAsFixed(2)),
      ));
    }
    
    return data;
  }
  
  // Generate market statistics
  static MarketStats generateMarketStats(String symbol) {
    final data = generateStockData(symbol, 2);
    final current = data.last;
    final previous = data.first;
    
    final changeAmount = current.price - previous.price;
    final changePercent = (changeAmount / previous.price) * 100;
    
    return MarketStats(
      currentPrice: current.price,
      changePercent: double.parse(changePercent.toStringAsFixed(2)),
      changeAmount: double.parse(changeAmount.toStringAsFixed(2)),
      dayHigh: current.high ?? current.price * 1.02,
      dayLow: current.low ?? current.price * 0.98,
      volume: current.volume,
      avgVolume: current.volume * (0.8 + _random.nextDouble() * 0.4),
    );
  }
  
  // Generate intraday data (for 1-day view)
  static List<StockData> generateIntradayData(String symbol, int intervals) {
    final basePrice = _basePrices[symbol] ?? 100.0;
    final data = <StockData>[];
    double price = basePrice;
    
    final now = DateTime.now();
    final marketOpen = DateTime(now.year, now.month, now.day, 9, 30);
    
    for (int i = 0; i < intervals; i++) {
      final timestamp = marketOpen.add(Duration(minutes: i * 5));
      
      final change = (_random.nextDouble() - 0.5) * basePrice * 0.01;
      price += change;
      
      data.add(StockData(
        timestamp: timestamp.toIso8601String(),
        price: double.parse(price.toStringAsFixed(2)),
        volume: (_random.nextDouble() * 1000000 + 100000),
      ));
    }
    
    return data;
  }
}
