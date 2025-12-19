import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import '../models/stock.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: AppConfig.geminiApiKey,
    );
  }
  
  // Generate AI analysis for a stock
  Future<String> analyzeStock({
    required Stock stock,
    required List<StockData> priceData,
    required MarketStats stats,
  }) async {
    if (!AppConfig.enableGeminiAI) {
      return _generateMockAnalysis(stock, stats);
    }
    
    try {
      final recentPrices = priceData
          .take(7)
          .map((d) => d.price.toStringAsFixed(2))
          .join(', ');
      
      final prompt = '''
You are a professional financial analyst providing market insights.

Stock: ${stock.name} (${stock.symbol})
Current Price: \$${stats.currentPrice.toStringAsFixed(2)}
Change: ${stats.changePercent >= 0 ? '+' : ''}${stats.changePercent.toStringAsFixed(2)}%
Day High: \$${stats.dayHigh.toStringAsFixed(2)}
Day Low: \$${stats.dayLow.toStringAsFixed(2)}
Volume: ${(stats.volume / 1000000).toStringAsFixed(1)}M
Recent prices (7 days): $recentPrices

Provide a professional analysis (4-5 sentences) covering:
1. Current price trend and momentum
2. Volume and volatility observations
3. Key technical indicators
4. Short-term outlook
5. Risk considerations

Use professional financial terminology but keep it accessible. Be objective and balanced.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? _generateMockAnalysis(stock, stats);
    } catch (e) {
      print('Gemini AI Error: $e');
      return _generateMockAnalysis(stock, stats);
    }
  }
  
  // Generate market sentiment analysis
  Future<String> generateMarketSentiment(
    List<Stock> stocks,
    Map<String, MarketStats> statsMap,
  ) async {
    try {
      final stockSummary = stocks.map((stock) {
        final stats = statsMap[stock.symbol];
        return '${stock.symbol}: ${stats?.changePercent.toStringAsFixed(2)}%';
      }).join(', ');
      
      final prompt = '''
Analyze overall market sentiment based on these major stocks:
$stockSummary

Provide a brief 2-3 sentence market overview covering:
- Overall market direction
- Sector performance
- Key trends to watch

Be concise and professional.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Market analysis unavailable.';
    } catch (e) {
      print('Market Sentiment Error: $e');
      return 'Market showing mixed signals with varied sector performance.';
    }
  }
  
  // Trading recommendation (not financial advice)
  Future<String> generateTradingInsight(
    Stock stock,
    List<StockData> historicalData,
  ) async {
    try {
      final prices = historicalData.take(14).map((d) => d.price).toList();
      final avgPrice = prices.reduce((a, b) => a + b) / prices.length;
      final currentPrice = prices.first;
      
      final prompt = '''
Based on ${stock.symbol} trading data:
- Current: \$${currentPrice.toStringAsFixed(2)}
- 14-day average: \$${avgPrice.toStringAsFixed(2)}
- Trend: ${currentPrice > avgPrice ? 'Above' : 'Below'} average

Provide a brief technical insight (2-3 sentences) about potential support/resistance levels and momentum. 
Include a disclaimer that this is not financial advice.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Technical analysis unavailable.';
    } catch (e) {
      print('Trading Insight Error: $e');
      return 'Unable to generate trading insights at this time.';
    }
  }
  
  String _generateMockAnalysis(Stock stock, MarketStats stats) {
    final trend = stats.changePercent >= 0 ? 'upward' : 'downward';
    final momentum = stats.changePercent.abs() > 2 ? 'strong' : 'moderate';
    
    return '''
${stock.name} is showing ${momentum} ${trend} momentum with a ${stats.changePercent.toStringAsFixed(2)}% change. Current price of \$${stats.currentPrice.toStringAsFixed(2)} is trading ${stats.currentPrice > (stats.dayHigh + stats.dayLow) / 2 ? 'above' : 'below'} the day's midpoint. Volume indicators suggest ${stats.volume > stats.avgVolume ? 'increased' : 'normal'} trading activity. Technical indicators point to ${stats.changePercent >= 0 ? 'bullish' : 'bearish'} sentiment in the near term. Risk remains ${stats.changePercent.abs() > 3 ? 'elevated' : 'moderate'} given current volatility levels.

*This analysis is for educational purposes only and not financial advice.*
''';
  }
}
