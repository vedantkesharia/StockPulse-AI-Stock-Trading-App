import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/stock.dart';
import '../utils/mock_data_generator.dart';

class AWSService {
  final String _baseUrl = AppConfig.awsLambdaUrl;
  
  // Fetch stock data from AWS Lambda
  Future<List<StockData>> fetchStockData(String symbol) async {
    print('🔵 Attempting to fetch from AWS: $_baseUrl');
    print('📊 Symbol: $symbol');
    print('🔑 API Key: ${AppConfig.awsApiKey.substring(0, 10)}...');
    
    if (!AppConfig.enableAWSIntegration) {
      throw Exception('AWS Integration is DISABLED in config');
    }
    
    if (AppConfig.useMockData) {
      throw Exception('Mock data mode is ENABLED - Disable it in config');
    }
    
    try {
      print('🚀 Sending POST request to AWS Lambda...');
      final uri = Uri.parse('$_baseUrl/stock-data');
      print('🌐 Full URL: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConfig.awsApiKey,
        },
        body: jsonEncode({
          'symbol': symbol,
          'interval': 'daily',
          'outputsize': 'compact',
        }),
      ).timeout(AppConfig.requestTimeout);
      
      print('✅ AWS Response Status: ${response.statusCode}');
      print('📦 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS - Data received from AWS!');
        print('📦 Response length: ${response.body.length} bytes');
        print('📦 Response preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        
        final data = jsonDecode(response.body);
        
        // Check if response has the expected structure
        if (data['timeSeries'] != null) {
          final stockDataList = (data['timeSeries'] as List)
              .map((item) => StockData.fromJson(item))
              .toList();
          print('✅ Parsed ${stockDataList.length} stock data points');
          return stockDataList;
        } else {
          throw Exception('Invalid response structure: missing timeSeries');
        }
      } else if (response.statusCode == 401) {
        throw Exception('❌ AWS Error 401: Invalid API Key');
      } else if (response.statusCode == 403) {
        throw Exception('❌ AWS Error 403: Access Forbidden - Check API Gateway permissions');
      } else if (response.statusCode == 404) {
        throw Exception('❌ AWS Error 404: Endpoint not found - Check Lambda URL');
      } else {
        throw Exception('❌ AWS Error ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('❌ Network Error: $e - Check internet connection');
    } on FormatException catch (e) {
      throw Exception('❌ JSON Parse Error: $e - Invalid response from AWS');
    } catch (e) {
      print('❌ AWS Service Error: $e');
      
      // Only use mock data if explicitly allowed
      if (AppConfig.allowMockFallback) {
        print('⚠️ Falling back to mock data (allowed by config)');
        return MockDataGenerator.generateStockData(symbol, 30);
      } else {
        throw Exception('❌ AWS Error: $e - Mock fallback is DISABLED');
      }
    }
  }
  
  // Fetch market statistics - FIXED: Calculate from stock data instead of separate endpoint
  Future<MarketStats> fetchMarketStats(String symbol) async {
    print('🔵 Calculating market stats from stock data');
    
    try {
      // Get stock data first
      final stockData = await fetchStockData(symbol);
      
      if (stockData.isEmpty) {
        throw Exception('No stock data available to calculate stats');
      }
      
      // Calculate stats from the data we have
      final currentData = stockData.first; // Most recent
      final previousData = stockData.length > 1 ? stockData[1] : stockData.first;
      
      final changeAmount = currentData.price - previousData.price;
      final changePercent = (changeAmount / previousData.price) * 100;
      
      // Find high and low from recent data
      final recentPrices = stockData.take(5).map((d) => d.price).toList();
      final dayHigh = recentPrices.reduce((a, b) => a > b ? a : b);
      final dayLow = recentPrices.reduce((a, b) => a < b ? a : b);
      
      // Calculate average volume
      final avgVolume = stockData
          .map((d) => d.volume)
          .reduce((a, b) => a + b) / stockData.length;
      
      final stats = MarketStats(
        currentPrice: currentData.price,
        changePercent: double.parse(changePercent.toStringAsFixed(2)),
        changeAmount: double.parse(changeAmount.toStringAsFixed(2)),
        dayHigh: dayHigh,
        dayLow: dayLow,
        volume: currentData.volume,
        avgVolume: avgVolume,
      );
      
      print('✅ Market stats calculated from AWS data');
      return stats;
      
    } catch (e) {
      print('❌ Market Stats Error: $e');
      
      // Only use mock data if explicitly allowed
      if (AppConfig.allowMockFallback) {
        print('⚠️ Falling back to mock market stats');
        return MockDataGenerator.generateMarketStats(symbol);
      } else {
        throw Exception('❌ AWS Market Stats Error: $e');
      }
    }
  }
  
  // Batch fetch multiple stocks
  Future<Map<String, List<StockData>>> fetchMultipleStocks(
    List<String> symbols,
  ) async {
    final results = <String, List<StockData>>{};
    
    for (final symbol in symbols) {
      try {
        results[symbol] = await fetchStockData(symbol);
      } catch (e) {
        print('❌ Failed to fetch $symbol: $e');
        // Skip failed symbols
      }
    }
    
    return results;
  }
}





// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/app_config.dart';
// import '../models/stock.dart';
// import '../utils/mock_data_generator.dart';

// class AWSService {
//   final String _baseUrl = AppConfig.awsLambdaUrl;
  
//   // Fetch stock data from AWS Lambda
//   Future<List<StockData>> fetchStockData(String symbol) async {
//     print('🔵 Attempting to fetch from AWS: $_baseUrl');
//     print('📊 Symbol: $symbol');
//     print('🔑 API Key: ${AppConfig.awsApiKey.substring(0, 10)}...');
    
//     if (!AppConfig.enableAWSIntegration) {
//       throw Exception('AWS Integration is DISABLED in config');
//     }
    
//     if (AppConfig.useMockData) {
//       throw Exception('Mock data mode is ENABLED - Disable it in config');
//     }
    
//     try {
//       print('🚀 Sending POST request to AWS Lambda...');
//       final uri = Uri.parse('$_baseUrl');
//       print('🌐 Full URL: $uri');
      
//       final response = await http.post(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'x-api-key': AppConfig.awsApiKey,
//         },
//         body: jsonEncode({
//           'symbol': symbol,
//           'interval': 'daily',
//           'outputsize': 'compact',
//         }),
//       ).timeout(AppConfig.requestTimeout);
      
//       print('✅ AWS Response Status: ${response.statusCode}');
//       print('📦 Response Headers: ${response.headers}');
      
//       if (response.statusCode == 200) {
//         print('✅ SUCCESS - Data received from AWS!');
//         print('📦 Response length: ${response.body.length} bytes');
//         print('📦 Response preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        
//         final data = jsonDecode(response.body);
        
//         // Check if response has the expected structure
//         if (data['timeSeries'] != null) {
//           final stockDataList = (data['timeSeries'] as List)
//               .map((item) => StockData.fromJson(item))
//               .toList();
//           print('✅ Parsed ${stockDataList.length} stock data points');
//           return stockDataList;
//         } else {
//           throw Exception('Invalid response structure: missing timeSeries');
//         }
//       } else if (response.statusCode == 401) {
//         throw Exception('❌ AWS Error 401: Invalid API Key');
//       } else if (response.statusCode == 403) {
//         throw Exception('❌ AWS Error 403: Access Forbidden - Check API Gateway permissions');
//       } else if (response.statusCode == 404) {
//         throw Exception('❌ AWS Error 404: Endpoint not found - Check Lambda URL');
//       } else {
//         throw Exception('❌ AWS Error ${response.statusCode}: ${response.body}');
//       }
//     } on http.ClientException catch (e) {
//       throw Exception('❌ Network Error: $e - Check internet connection');
//     } on FormatException catch (e) {
//       throw Exception('❌ JSON Parse Error: $e - Invalid response from AWS');
//     } catch (e) {
//       print('❌ AWS Service Error: $e');
      
//       // Only use mock data if explicitly allowed
//       if (AppConfig.allowMockFallback) {
//         print('⚠️ Falling back to mock data (allowed by config)');
//         return MockDataGenerator.generateStockData(symbol, 30);
//       } else {
//         throw Exception('❌ AWS Error: $e - Mock fallback is DISABLED');
//       }
//     }
//   }
  
//   // Fetch market statistics
//   Future<MarketStats> fetchMarketStats(String symbol) async {
//     print('🔵 Attempting to fetch market stats from AWS');
    
//     if (!AppConfig.enableAWSIntegration) {
//       throw Exception('AWS Integration is DISABLED');
//     }
    
//     if (AppConfig.useMockData) {
//       throw Exception('Mock data mode is ENABLED');
//     }
    
//     try {
//       print('🚀 Fetching market stats for $symbol...');
//       final uri = Uri.parse('$_baseUrl/market-stats/$symbol');
      
//       final response = await http.get(
//         uri,
//         headers: {
//           'x-api-key': AppConfig.awsApiKey,
//         },
//       ).timeout(AppConfig.requestTimeout);
      
//       print('✅ Market Stats Response: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         print('✅ Market stats from AWS received');
//         return MarketStats.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('❌ Failed to fetch market stats: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Market Stats Error: $e');
      
//       // Only use mock data if explicitly allowed
//       if (AppConfig.allowMockFallback) {
//         print('⚠️ Falling back to mock market stats');
//         return MockDataGenerator.generateMarketStats(symbol);
//       } else {
//         throw Exception('❌ AWS Market Stats Error: $e');
//       }
//     }
//   }
  
//   // Batch fetch multiple stocks (AWS Lambda can handle this efficiently)
//   Future<Map<String, List<StockData>>> fetchMultipleStocks(
//     List<String> symbols,
//   ) async {
//     final results = <String, List<StockData>>{};
    
//     for (final symbol in symbols) {
//       try {
//         results[symbol] = await fetchStockData(symbol);
//       } catch (e) {
//         print('❌ Failed to fetch $symbol: $e');
//         // Skip failed symbols
//       }
//     }
    
//     return results;
//   }
// }






// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/app_config.dart';
// import '../models/stock.dart';
// import '../utils/mock_data_generator.dart';

// class AWSService {
//   final String _baseUrl = AppConfig.awsLambdaUrl;
  
//   // Fetch stock data from AWS Lambda
//   Future<List<StockData>> fetchStockData(String symbol) async {
//     print('🔵 Attempting to fetch from AWS: $_baseUrl/stock-data');
//     print('📊 Symbol: $symbol');
    
//     if (!AppConfig.enableAWSIntegration) {
//       print('⚠️ AWS Integration DISABLED - Using mock data');
//       await Future.delayed(AppConfig.mockDataDelay);
//       return MockDataGenerator.generateStockData(symbol, 30);
//     }
    
//     if (AppConfig.useMockData) {
//       print('⚠️ Mock data mode ENABLED - Using mock data');
//       await Future.delayed(AppConfig.mockDataDelay);
//       return MockDataGenerator.generateStockData(symbol, 30);
//     }
    
//     try {
//       print('🚀 Sending request to AWS...');
//       final response = await http.post(
//         Uri.parse('$_baseUrl/stock-data'),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-api-key': AppConfig.awsApiKey,
//         },
//         body: jsonEncode({
//           'symbol': symbol,
//           'interval': 'daily',
//           'outputsize': 'compact',
//         }),
//       ).timeout(AppConfig.requestTimeout);
      
//       print('✅ AWS Response Status: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         print('✅ SUCCESS - Data received from AWS!');
//         print('📦 Response length: ${response.body.length} bytes');
//         final data = jsonDecode(response.body);
//         return (data['timeSeries'] as List)
//             .map((item) => StockData.fromJson(item))
//             .toList();
//       } else {
//         print('❌ AWS Error: Status ${response.statusCode}');
//         print('❌ Response: ${response.body}');
//         throw Exception('AWS Lambda returned ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ AWS Service Error: $e');
//       print('⚠️ Falling back to mock data');
//       return MockDataGenerator.generateStockData(symbol, 30);
//     }
//   }
  
//   // Fetch market statistics
//   Future<MarketStats> fetchMarketStats(String symbol) async {
//     print('🔵 Attempting to fetch market stats from AWS');
    
//     if (!AppConfig.enableAWSIntegration || AppConfig.useMockData) {
//       print('⚠️ Using mock market stats');
//       await Future.delayed(const Duration(milliseconds: 500));
//       return MockDataGenerator.generateMarketStats(symbol);
//     }
    
//     try {
//       print('🚀 Fetching market stats...');
//       final response = await http.get(
//         Uri.parse('$_baseUrl/market-stats/$symbol'),
//         headers: {
//           'x-api-key': AppConfig.awsApiKey,
//         },
//       ).timeout(AppConfig.requestTimeout);
      
//       print('✅ Market Stats Response: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         print('✅ Market stats from AWS received');
//         return MarketStats.fromJson(jsonDecode(response.body));
//       } else {
//         print('❌ Failed to fetch market stats: ${response.statusCode}');
//         throw Exception('Failed to fetch market stats');
//       }
//     } catch (e) {
//       print('❌ Market Stats Error: $e');
//       return MockDataGenerator.generateMarketStats(symbol);
//     }
//   }
  
//   // Batch fetch multiple stocks
//   Future<Map<String, List<StockData>>> fetchMultipleStocks(
//     List<String> symbols,
//   ) async {
//     final results = <String, List<StockData>>{};
    
//     for (final symbol in symbols) {
//       results[symbol] = await fetchStockData(symbol);
//     }
    
//     return results;
//   }
// }






// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/app_config.dart';
// import '../models/stock.dart';
// import '../utils/mock_data_generator.dart';

// class AWSService {
//   final String _baseUrl = AppConfig.awsLambdaUrl;
  
//   // Fetch stock data from AWS Lambda
//   Future<List<StockData>> fetchStockData(String symbol) async {
//     if (!AppConfig.enableAWSIntegration || AppConfig.useMockData) {
//       // Use mock data for development
//       await Future.delayed(AppConfig.mockDataDelay);
//       return MockDataGenerator.generateStockData(symbol, 30);
//     }
    
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/stock-data'),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-api-key': AppConfig.awsApiKey,
//         },
//         body: jsonEncode({
//           'symbol': symbol,
//           'interval': 'daily',
//           'outputsize': 'compact',
//         }),
//       ).timeout(AppConfig.requestTimeout);
      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return (data['timeSeries'] as List)
//             .map((item) => StockData.fromJson(item))
//             .toList();
//       } else {
//         throw Exception('AWS Lambda returned ${response.statusCode}');
//       }
//     } catch (e) {
//       print('AWS Service Error: $e');
//       // Fallback to mock data
//       return MockDataGenerator.generateStockData(symbol, 30);
//     }
//   }
  
//   // Fetch market statistics
//   Future<MarketStats> fetchMarketStats(String symbol) async {
//     if (!AppConfig.enableAWSIntegration || AppConfig.useMockData) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       return MockDataGenerator.generateMarketStats(symbol);
//     }
    
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/market-stats/$symbol'),
//         headers: {
//           'x-api-key': AppConfig.awsApiKey,
//         },
//       ).timeout(AppConfig.requestTimeout);
      
//       if (response.statusCode == 200) {
//         return MarketStats.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to fetch market stats');
//       }
//     } catch (e) {
//       print('Market Stats Error: $e');
//       return MockDataGenerator.generateMarketStats(symbol);
//     }
//   }
  
//   // Batch fetch multiple stocks (AWS Lambda can handle this efficiently)
//   Future<Map<String, List<StockData>>> fetchMultipleStocks(
//     List<String> symbols,
//   ) async {
//     final results = <String, List<StockData>>{};
    
//     for (final symbol in symbols) {
//       results[symbol] = await fetchStockData(symbol);
//     }
    
//     return results;
//   }
// }