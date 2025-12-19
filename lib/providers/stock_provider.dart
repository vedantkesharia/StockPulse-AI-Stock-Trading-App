import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../services/gemini_service.dart';
import '../services/aws_service.dart';
// import '../utils/mock_data_generator.dart';

class StockProvider with ChangeNotifier {
  final GeminiService geminiService;
  final AWSService awsService;
  
  StockProvider({
    required this.geminiService,
    required this.awsService,
  });
  
  // Available stocks
  final List<Stock> _availableStocks = [
    Stock(symbol: 'AAPL', name: 'Apple Inc.', description: 'Technology'),
    Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', description: 'Technology'),
    Stock(symbol: 'MSFT', name: 'Microsoft Corp.', description: 'Technology'),
    Stock(symbol: 'TSLA', name: 'Tesla Inc.', description: 'Automotive'),
    Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', description: 'E-commerce'),
    Stock(symbol: 'NVDA', name: 'NVIDIA Corp.', description: 'Semiconductors'),
    Stock(symbol: 'META', name: 'Meta Platforms', description: 'Social Media'),
  ];
  
  List<Stock> get availableStocks => _availableStocks;
  
  // Selected stock
  Stock _selectedStock = Stock(symbol: 'AAPL', name: 'Apple Inc.');
  Stock get selectedStock => _selectedStock;
  
  // Stock data
  List<StockData> _stockData = [];
  List<StockData> _originalStockData = [];
  List<StockData> get stockData => _stockData;
  
  // Market stats
  MarketStats? _marketStats;
  MarketStats? get marketStats => _marketStats;
  
  // AI Analysis
  String _aiAnalysis = '';
  String get aiAnalysis => _aiAnalysis;
  
  // Loading states
  bool _isLoadingData = false;
  bool _isLoadingAI = false;
  bool get isLoadingData => _isLoadingData;
  bool get isLoadingAI => _isLoadingAI;
  
  // Error handling
  String? _error;
  String? get error => _error;
  
  // Timeframe
  String _currentTimeframe = '1M';
  String get currentTimeframe => _currentTimeframe;
  
  // Select a stock
  void selectStock(Stock stock) {
    _selectedStock = stock;
    _aiAnalysis = '';
    _currentTimeframe = '1M';
    notifyListeners();
    loadStockData();
  }
  
  // Load stock data from AWS
  Future<void> loadStockData() async {
    _isLoadingData = true;
    _error = null;
    notifyListeners();
    
    try {
      print('📡 Loading stock data for ${_selectedStock.symbol}...');
      
      // Fetch data from AWS (only once!)
      final data = await awsService.fetchStockData(_selectedStock.symbol);
      
      if (data.isEmpty) {
        throw Exception('No stock data received from AWS');
      }
      
      _originalStockData = data;
      _stockData = data;
      
      // Calculate market stats from the data we just fetched
      _marketStats = _calculateMarketStats(data);
      
      _error = null;
      _currentTimeframe = '1M';
      
      print('✅ Loaded ${data.length} data points');
      print('✅ Market stats calculated locally');
    } catch (e) {
      _error = 'Failed to load stock data: ${e.toString()}';
      print('❌ Load Error: $_error');
      _stockData = [];
      _originalStockData = [];
      _marketStats = null;
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }
  
  // Calculate market stats from stock data (NO API CALL)
  MarketStats _calculateMarketStats(List<StockData> data) {
    if (data.isEmpty) {
      throw Exception('No data to calculate stats');
    }
    
    final currentData = data.first; // Most recent
    final previousData = data.length > 1 ? data[1] : data.first;
    
    final changeAmount = currentData.price - previousData.price;
    final changePercent = (changeAmount / previousData.price) * 100;
    
    // Find high and low from recent data (last 5 days)
    final recentPrices = data.take(5).map((d) => d.price).toList();
    final dayHigh = recentPrices.reduce((a, b) => a > b ? a : b);
    final dayLow = recentPrices.reduce((a, b) => a < b ? a : b);
    
    // Calculate average volume
    final avgVolume = data
        .map((d) => d.volume)
        .reduce((a, b) => a + b) / data.length;
    
    return MarketStats(
      currentPrice: currentData.price,
      changePercent: double.parse(changePercent.toStringAsFixed(2)),
      changeAmount: double.parse(changeAmount.toStringAsFixed(2)),
      dayHigh: dayHigh,
      dayLow: dayLow,
      volume: currentData.volume,
      avgVolume: avgVolume,
    );
  }
  
  // Update timeframe and filter data
  void updateTimeframe(String timeframe) {
    _currentTimeframe = timeframe;
    _applyTimeframeFilter();
    notifyListeners();
  }
  
  // Apply timeframe filter to stock data
  void _applyTimeframeFilter() {
    int days = 30;
    switch (_currentTimeframe) {
      case '1D':
        days = 1;
        break;
      case '1W':
        days = 7;
        break;
      case '1M':
        days = 30;
        break;
      case '3M':
        days = 90;
        break;
      case '1Y':
        days = 365;
        break;
    }
    
    print('🔄 Filtering data for timeframe: $_currentTimeframe ($days days)');
    
    if (_originalStockData.length < days) {
      print('⚠️ Not enough data, using all ${_originalStockData.length} points');
      _stockData = _originalStockData;
    } else {
      final cutoffIndex = (_originalStockData.length - days).clamp(0, _originalStockData.length);
      _stockData = _originalStockData.sublist(cutoffIndex);
      print('✅ Filtered to ${_stockData.length} data points');
    }
  }
  
  // Generate AI analysis using Gemini
  Future<void> generateAIAnalysis() async {
    if (_marketStats == null || _stockData.isEmpty) {
      _error = 'No data available for analysis';
      notifyListeners();
      return;
    }
    
    _isLoadingAI = true;
    _aiAnalysis = '';
    notifyListeners();
    
    try {
      final analysis = await geminiService.analyzeStock(
        stock: _selectedStock,
        priceData: _stockData,
        stats: _marketStats!,
      );
      
      _aiAnalysis = analysis;
      _error = null;
    } catch (e) {
      _error = 'Failed to generate AI analysis: ${e.toString()}';
      _aiAnalysis = 'Unable to generate analysis. Please try again.';
      print(_error);
    } finally {
      _isLoadingAI = false;
      notifyListeners();
    }
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    await loadStockData();
    if (_aiAnalysis.isNotEmpty) {
      await generateAIAnalysis();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}







// import 'package:flutter/foundation.dart';
// import '../models/stock.dart';
// import '../services/gemini_service.dart';
// import '../services/aws_service.dart';
// import '../utils/mock_data_generator.dart';

// class StockProvider with ChangeNotifier {
//   final GeminiService geminiService;
//   final AWSService awsService;
  
//   StockProvider({
//     required this.geminiService,
//     required this.awsService,
//   });
  
//   // Available stocks
//   final List<Stock> _availableStocks = [
//     Stock(symbol: 'AAPL', name: 'Apple Inc.', description: 'Technology'),
//     Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', description: 'Technology'),
//     Stock(symbol: 'MSFT', name: 'Microsoft Corp.', description: 'Technology'),
//     Stock(symbol: 'TSLA', name: 'Tesla Inc.', description: 'Automotive'),
//     Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', description: 'E-commerce'),
//     Stock(symbol: 'NVDA', name: 'NVIDIA Corp.', description: 'Semiconductors'),
//     Stock(symbol: 'META', name: 'Meta Platforms', description: 'Social Media'),
//   ];
  
//   List<Stock> get availableStocks => _availableStocks;
  
//   // Selected stock
//   Stock _selectedStock = Stock(symbol: 'AAPL', name: 'Apple Inc.');
//   Stock get selectedStock => _selectedStock;
  
//   // Stock data
//   List<StockData> _stockData = [];
//   List<StockData> _originalStockData = []; // Store original full dataset
//   List<StockData> get stockData => _stockData;
  
//   // Market stats
//   MarketStats? _marketStats;
//   MarketStats? get marketStats => _marketStats;
  
//   // AI Analysis
//   String _aiAnalysis = '';
//   String get aiAnalysis => _aiAnalysis;
  
//   // Loading states
//   bool _isLoadingData = false;
//   bool _isLoadingAI = false;
//   bool get isLoadingData => _isLoadingData;
//   bool get isLoadingAI => _isLoadingAI;
  
//   // Error handling
//   String? _error;
//   String? get error => _error;
  
//   // Timeframe
//   String _currentTimeframe = '1M';
//   String get currentTimeframe => _currentTimeframe;
  
//   // Select a stock
//   void selectStock(Stock stock) {
//     _selectedStock = stock;
//     _aiAnalysis = '';
//     _currentTimeframe = '1M'; // Reset to default
//     notifyListeners();
//     loadStockData();
//   }
  
//   // Load stock data from AWS
//   Future<void> loadStockData() async {
//     _isLoadingData = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       print('📡 Loading stock data for ${_selectedStock.symbol}...');
      
//       // Fetch data from AWS (NO MOCK FALLBACK)
//       final data = await awsService.fetchStockData(_selectedStock.symbol);
//       final stats = await awsService.fetchMarketStats(_selectedStock.symbol);
      
//       _originalStockData = data;
//       _stockData = data;
//       _marketStats = stats;
//       _error = null;
//       _currentTimeframe = '1M'; // Reset timeframe
      
//       print('✅ Loaded ${data.length} data points');
//     } catch (e) {
//       _error = 'Failed to load stock data: ${e.toString()}';
//       print('❌ Load Error: $_error');
//       _stockData = [];
//       _originalStockData = [];
//       _marketStats = null;
//     } finally {
//       _isLoadingData = false;
//       notifyListeners();
//     }
//   }
  
//   // Update timeframe and filter data
//   void updateTimeframe(String timeframe) {
//     _currentTimeframe = timeframe;
//     _applyTimeframeFilter();
//     notifyListeners();
//   }
  
//   // Apply timeframe filter to stock data
//   void _applyTimeframeFilter() {
//     // Get the number of days based on timeframe
//     int days = 30; // Default 1M
//     switch (_currentTimeframe) {
//       case '1D':
//         days = 1;
//         break;
//       case '1W':
//         days = 7;
//         break;
//       case '1M':
//         days = 30;
//         break;
//       case '3M':
//         days = 90;
//         break;
//       case '1Y':
//         days = 365;
//         break;
//     }
    
//     print('🔄 Filtering data for timeframe: $_currentTimeframe ($days days)');
    
//     // If we don't have enough original data, regenerate it (mock for demo)
//     if (_originalStockData.length < days) {
//       print('⚠️ Not enough data, generating $days days worth');
//       _stockData = MockDataGenerator.generateStockData(_selectedStock.symbol, days);
//       _originalStockData = _stockData;
//     } else {
//       // Filter to show only the requested timeframe
//       final cutoffIndex = (_originalStockData.length - days).clamp(0, _originalStockData.length);
//       _stockData = _originalStockData.sublist(cutoffIndex);
//       print('✅ Filtered to ${_stockData.length} data points');
//     }
//   }
  
//   // Generate AI analysis using Gemini
//   Future<void> generateAIAnalysis() async {
//     if (_marketStats == null || _stockData.isEmpty) {
//       _error = 'No data available for analysis';
//       notifyListeners();
//       return;
//     }
    
//     _isLoadingAI = true;
//     _aiAnalysis = '';
//     notifyListeners();
    
//     try {
//       final analysis = await geminiService.analyzeStock(
//         stock: _selectedStock,
//         priceData: _stockData,
//         stats: _marketStats!,
//       );
      
//       _aiAnalysis = analysis;
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to generate AI analysis: ${e.toString()}';
//       _aiAnalysis = 'Unable to generate analysis. Please try again.';
//       print(_error);
//     } finally {
//       _isLoadingAI = false;
//       notifyListeners();
//     }
//   }
  
//   // Refresh all data
//   Future<void> refreshData() async {
//     await loadStockData();
//     if (_aiAnalysis.isNotEmpty) {
//       await generateAIAnalysis();
//     }
//   }
  
//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }








// import 'package:flutter/foundation.dart';
// import '../models/stock.dart';
// import '../services/gemini_service.dart';
// import '../services/aws_service.dart';
// import '../utils/mock_data_generator.dart';

// class StockProvider with ChangeNotifier {
//   final GeminiService geminiService;
//   final AWSService awsService;
  
//   StockProvider({
//     required this.geminiService,
//     required this.awsService,
//   });
  
//   // Available stocks
//   final List<Stock> _availableStocks = [
//     Stock(symbol: 'AAPL', name: 'Apple Inc.', description: 'Technology'),
//     Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', description: 'Technology'),
//     Stock(symbol: 'MSFT', name: 'Microsoft Corp.', description: 'Technology'),
//     Stock(symbol: 'TSLA', name: 'Tesla Inc.', description: 'Automotive'),
//     Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', description: 'E-commerce'),
//     Stock(symbol: 'NVDA', name: 'NVIDIA Corp.', description: 'Semiconductors'),
//     Stock(symbol: 'META', name: 'Meta Platforms', description: 'Social Media'),
//   ];
  
//   List<Stock> get availableStocks => _availableStocks;
  
//   // Selected stock
//   Stock _selectedStock = Stock(symbol: 'AAPL', name: 'Apple Inc.');
//   Stock get selectedStock => _selectedStock;
  
//   // Stock data
//   List<StockData> _stockData = [];
//   List<StockData> _originalStockData = []; // Store original data
//   List<StockData> get stockData => _stockData;
  
//   // Market stats
//   MarketStats? _marketStats;
//   MarketStats? get marketStats => _marketStats;
  
//   // AI Analysis
//   String _aiAnalysis = '';
//   String get aiAnalysis => _aiAnalysis;
  
//   // Loading states
//   bool _isLoadingData = false;
//   bool _isLoadingAI = false;
//   bool get isLoadingData => _isLoadingData;
//   bool get isLoadingAI => _isLoadingAI;
  
//   // Error handling
//   String? _error;
//   String? get error => _error;
  
//   // Timeframe
//   String _currentTimeframe = '1M';
//   String get currentTimeframe => _currentTimeframe;
  
//   // Select a stock
//   void selectStock(Stock stock) {
//     _selectedStock = stock;
//     _aiAnalysis = '';
//     _currentTimeframe = '1M'; // Reset to default timeframe
//     notifyListeners();
//     loadStockData();
//   }
  
//   // Load stock data from AWS
//   Future<void> loadStockData() async {
//     _isLoadingData = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       // Fetch data from AWS (or mock data)
//       final data = await awsService.fetchStockData(_selectedStock.symbol);
//       final stats = await awsService.fetchMarketStats(_selectedStock.symbol);
      
//       _originalStockData = data;
//       _stockData = data;
//       _marketStats = stats;
//       _error = null;
//       _currentTimeframe = '1M'; // Reset timeframe filter
//     } catch (e) {
//       _error = 'Failed to load stock data: ${e.toString()}';
//       print(_error);
//     } finally {
//       _isLoadingData = false;
//       notifyListeners();
//     }
//   }
  
//   // Update timeframe and filter data
//   void updateTimeframe(String timeframe) {
//     _currentTimeframe = timeframe;
//     _applyTimeframeFilter();
//     notifyListeners();
//   }
  
//   // Apply timeframe filter to stock data
//   void _applyTimeframeFilter() {
//     // Get the number of days based on timeframe
//     int days = 30; // Default 1M
//     switch (_currentTimeframe) {
//       case '1D':
//         days = 1;
//         break;
//       case '1W':
//         days = 7;
//         break;
//       case '1M':
//         days = 30;
//         break;
//       case '3M':
//         days = 90;
//         break;
//       case '1Y':
//         days = 365;
//         break;
//     }
    
//     // If we don't have enough data, regenerate it
//     if (_originalStockData.length < days) {
//       _stockData = MockDataGenerator.generateStockData(_selectedStock.symbol, days);
//       _originalStockData = _stockData;
//     } else {
//       // Filter to show only the requested timeframe
//       final cutoffIndex = (_originalStockData.length - days).clamp(0, _originalStockData.length);
//       _stockData = _originalStockData.sublist(cutoffIndex);
//     }
//   }
  
//   // Generate AI analysis using Gemini
//   Future<void> generateAIAnalysis() async {
//     if (_marketStats == null || _stockData.isEmpty) {
//       _error = 'No data available for analysis';
//       notifyListeners();
//       return;
//     }
    
//     _isLoadingAI = true;
//     _aiAnalysis = '';
//     notifyListeners();
    
//     try {
//       final analysis = await geminiService.analyzeStock(
//         stock: _selectedStock,
//         priceData: _stockData,
//         stats: _marketStats!,
//       );
      
//       _aiAnalysis = analysis;
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to generate AI analysis: ${e.toString()}';
//       _aiAnalysis = 'Unable to generate analysis. Please try again.';
//       print(_error);
//     } finally {
//       _isLoadingAI = false;
//       notifyListeners();
//     }
//   }
  
//   // Refresh all data
//   Future<void> refreshData() async {
//     await loadStockData();
//     if (_aiAnalysis.isNotEmpty) {
//       await generateAIAnalysis();
//     }
//   }
  
//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }





// import 'package:flutter/foundation.dart';
// import '../models/stock.dart';
// import '../services/gemini_service.dart';
// import '../services/aws_service.dart';

// class StockProvider with ChangeNotifier {
//   final GeminiService geminiService;
//   final AWSService awsService;
  
//   StockProvider({
//     required this.geminiService,
//     required this.awsService,
//   });
  
//   // Available stocks
//   final List<Stock> _availableStocks = [
//     Stock(symbol: 'AAPL', name: 'Apple Inc.', description: 'Technology'),
//     Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', description: 'Technology'),
//     Stock(symbol: 'MSFT', name: 'Microsoft Corp.', description: 'Technology'),
//     Stock(symbol: 'TSLA', name: 'Tesla Inc.', description: 'Automotive'),
//     Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', description: 'E-commerce'),
//     Stock(symbol: 'NVDA', name: 'NVIDIA Corp.', description: 'Semiconductors'),
//     Stock(symbol: 'META', name: 'Meta Platforms', description: 'Social Media'),
//   ];
  
//   List<Stock> get availableStocks => _availableStocks;
  
//   // Selected stock
//   Stock _selectedStock = Stock(symbol: 'AAPL', name: 'Apple Inc.');
//   Stock get selectedStock => _selectedStock;
  
//   // Stock data
//   List<StockData> _stockData = [];
//   List<StockData> get stockData => _stockData;
  
//   // Market stats
//   MarketStats? _marketStats;
//   MarketStats? get marketStats => _marketStats;
  
//   // AI Analysis
//   String _aiAnalysis = '';
//   String get aiAnalysis => _aiAnalysis;
  
//   // Loading states
//   bool _isLoadingData = false;
//   bool _isLoadingAI = false;
//   bool get isLoadingData => _isLoadingData;
//   bool get isLoadingAI => _isLoadingAI;
  
//   // Error handling
//   String? _error;
//   String? get error => _error;
  
//   // Select a stock
//   void selectStock(Stock stock) {
//     _selectedStock = stock;
//     _aiAnalysis = '';
//     notifyListeners();
//     loadStockData();
//   }
  
//   // Load stock data from AWS
//   Future<void> loadStockData() async {
//     _isLoadingData = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       // Fetch data from AWS (or mock data)
//       final data = await awsService.fetchStockData(_selectedStock.symbol);
//       final stats = await awsService.fetchMarketStats(_selectedStock.symbol);
      
//       _stockData = data;
//       _marketStats = stats;
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to load stock data: ${e.toString()}';
//       print(_error);
//     } finally {
//       _isLoadingData = false;
//       notifyListeners();
//     }
//   }
  
//   // Generate AI analysis using Gemini
//   Future<void> generateAIAnalysis() async {
//     if (_marketStats == null || _stockData.isEmpty) {
//       _error = 'No data available for analysis';
//       notifyListeners();
//       return;
//     }
    
//     _isLoadingAI = true;
//     _aiAnalysis = '';
//     notifyListeners();
    
//     try {
//       final analysis = await geminiService.analyzeStock(
//         stock: _selectedStock,
//         priceData: _stockData,
//         stats: _marketStats!,
//       );
      
//       _aiAnalysis = analysis;
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to generate AI analysis: ${e.toString()}';
//       _aiAnalysis = 'Unable to generate analysis. Please try again.';
//       print(_error);
//     } finally {
//       _isLoadingAI = false;
//       notifyListeners();
//     }
//   }
  
//   // Refresh all data
//   Future<void> refreshData() async {
//     await loadStockData();
//     if (_aiAnalysis.isNotEmpty) {
//       await generateAIAnalysis();
//     }
//   }
  
//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }