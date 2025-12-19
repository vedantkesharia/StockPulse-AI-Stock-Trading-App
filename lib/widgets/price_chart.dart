import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/stock_provider.dart';
import '../config/app_config.dart';

class PriceChart extends StatefulWidget {
  const PriceChart({Key? key}) : super(key: key);

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  String selectedTimeframe = '1M';
  
  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1f3a),
                const Color(0xFF0f1229),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartHeader(context),
              const SizedBox(height: 8),
              _buildTimeframeSelector(provider),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: provider.isLoadingData
                    ? _buildLoadingChart()
                    : _buildChart(provider),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildChartHeader(BuildContext context) {
    // Determine data source based on config
    final bool isUsingMockData = AppConfig.useMockData || !AppConfig.enableAWSIntegration;
    final String badgeText = isUsingMockData ? 'Mock Data' : 'AWS Live';
    final Color badgeColor = isUsingMockData ? Colors.orange : const Color(0xFF00d4aa);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Text(
          'Price Chart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeframeSelector(StockProvider provider) {
    final timeframes = ['1D', '1W', '1M', '3M', '1Y'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeframes.map((tf) {
          final isSelected = tf == selectedTimeframe;
          return GestureDetector(
            onTap: () {
              setState(() => selectedTimeframe = tf);
              provider.updateTimeframe(tf);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tf,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[500],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildChart(StockProvider provider) {
    if (provider.stockData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    final data = provider.stockData;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: data.length / 5 > 0 ? data.length / 5 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = DateTime.parse(data[index].timestamp);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      '${date.month}/${date.day}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 9,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: const Color(0xFF1a1f3a),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < data.length) {
                  final date = DateTime.parse(data[index].timestamp);
                  return LineTooltipItem(
                    '\$${spot.y.toStringAsFixed(2)}\n${date.month}/${date.day}/${date.year}',
                    const TextStyle(
                      color: Color(0xFF00d4aa),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return LineTooltipItem('', const TextStyle());
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.price);
            }).toList(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
            ),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00d4aa).withOpacity(0.3),
                  const Color(0xFF0099ff).withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingChart() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1a1f3a),
      highlightColor: const Color(0xFF2a2f4a),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1f3a),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shimmer/shimmer.dart';
// import '../providers/stock_provider.dart';

// class PriceChart extends StatefulWidget {
//   const PriceChart({Key? key}) : super(key: key);

//   @override
//   State<PriceChart> createState() => _PriceChartState();
// }

// class _PriceChartState extends State<PriceChart> {
//   String selectedTimeframe = '1M';
  
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StockProvider>(
//       builder: (context, provider, _) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 const Color(0xFF1a1f3a),
//                 const Color(0xFF0f1229),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.1),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildChartHeader(context),
//               const SizedBox(height: 8),
//               _buildTimeframeSelector(provider),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 280,
//                 child: provider.isLoadingData
//                     ? _buildLoadingChart()
//                     : _buildChart(provider),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildChartHeader(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//             ),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
//         ),
//         const SizedBox(width: 12),
//         const Text(
//           'Price Chart',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const Spacer(),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: const Color(0xFF00d4aa).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 6,
//                 height: 6,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF00d4aa),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               const Text(
//                 'Mock Data',
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Color(0xFF00d4aa),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildTimeframeSelector(StockProvider provider) {
//     final timeframes = ['1D', '1W', '1M', '3M', '1Y'];
    
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: timeframes.map((tf) {
//           final isSelected = tf == selectedTimeframe;
//           return GestureDetector(
//             onTap: () {
//               setState(() => selectedTimeframe = tf);
//               provider.updateTimeframe(tf);
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               margin: const EdgeInsets.only(right: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//               decoration: BoxDecoration(
//                 gradient: isSelected
//                     ? const LinearGradient(
//                         colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//                       )
//                     : null,
//                 color: isSelected ? null : Colors.white.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 tf,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? Colors.white : Colors.grey[500],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
  
//   Widget _buildChart(StockProvider provider) {
//     if (provider.stockData.isEmpty) {
//       return const Center(
//         child: Text(
//           'No data available',
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }
    
//     final data = provider.stockData;
    
//     return LineChart(
//       LineChartData(
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 10,
//           getDrawingHorizontalLine: (value) {
//             return FlLine(
//               color: Colors.white.withOpacity(0.05),
//               strokeWidth: 1,
//             );
//           },
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           rightTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           topTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 28,
//               interval: data.length / 5 > 0 ? data.length / 5 : 1,
//               getTitlesWidget: (value, meta) {
//                 final index = value.toInt();
//                 if (index >= 0 && index < data.length) {
//                   final date = DateTime.parse(data[index].timestamp);
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 6.0),
//                     child: Text(
//                       '${date.month}/${date.day}',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 9,
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   '\$${value.toInt()}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 9,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         lineTouchData: LineTouchData(
//           enabled: true,
//           touchTooltipData: LineTouchTooltipData(
//             tooltipBgColor: const Color(0xFF1a1f3a),
//             tooltipRoundedRadius: 8,
//             getTooltipItems: (touchedSpots) {
//               return touchedSpots.map((spot) {
//                 final index = spot.x.toInt();
//                 if (index >= 0 && index < data.length) {
//                   final date = DateTime.parse(data[index].timestamp);
//                   return LineTooltipItem(
//                     '\$${spot.y.toStringAsFixed(2)}\n${date.month}/${date.day}/${date.year}',
//                     const TextStyle(
//                       color: Color(0xFF00d4aa),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   );
//                 }
//                 return LineTooltipItem('', const TextStyle());
//               }).toList();
//             },
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//             spots: data.asMap().entries.map((entry) {
//               return FlSpot(entry.key.toDouble(), entry.value.price);
//             }).toList(),
//             isCurved: true,
//             gradient: const LinearGradient(
//               colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//             ),
//             barWidth: 2.5,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: false),
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF00d4aa).withOpacity(0.3),
//                   const Color(0xFF0099ff).withOpacity(0.05),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildLoadingChart() {
//     return Shimmer.fromColors(
//       baseColor: const Color(0xFF1a1f3a),
//       highlightColor: const Color(0xFF2a2f4a),
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1a1f3a),
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shimmer/shimmer.dart';
// import '../providers/stock_provider.dart';

// class PriceChart extends StatefulWidget {
//   const PriceChart({Key? key}) : super(key: key);

//   @override
//   State<PriceChart> createState() => _PriceChartState();
// }

// class _PriceChartState extends State<PriceChart> {
//   String selectedTimeframe = '1M';
  
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StockProvider>(
//       builder: (context, provider, _) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 const Color(0xFF1a1f3a),
//                 const Color(0xFF0f1229),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.1),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildChartHeader(context),
//               const SizedBox(height: 8),
//               _buildTimeframeSelector(),
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 300,
//                 child: provider.isLoadingData
//                     ? _buildLoadingChart()
//                     : _buildChart(provider),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildChartHeader(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//             ),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
//         ),
//         const SizedBox(width: 12),
//         const Text(
//           'Price Chart',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const Spacer(),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: const Color(0xFF00d4aa).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 6,
//                 height: 6,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF00d4aa),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               const Text(
//                 'AWS Synced',
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Color(0xFF00d4aa),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildTimeframeSelector() {
//     final timeframes = ['1D', '1W', '1M', '3M', '1Y'];
    
//     return Row(
//       children: timeframes.map((tf) {
//         final isSelected = tf == selectedTimeframe;
//         return GestureDetector(
//           onTap: () => setState(() => selectedTimeframe = tf),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.only(right: 8),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: isSelected
//                   ? const LinearGradient(
//                       colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//                     )
//                   : null,
//               color: isSelected ? null : Colors.white.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               tf,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? Colors.white : Colors.grey[500],
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
  
//   Widget _buildChart(StockProvider provider) {
//     if (provider.stockData.isEmpty) {
//       return const Center(
//         child: Text(
//           'No data available',
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }
    
//     final data = provider.stockData;
    
//     return LineChart(
//       LineChartData(
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 10,
//           getDrawingHorizontalLine: (value) {
//             return FlLine(
//               color: Colors.white.withOpacity(0.05),
//               strokeWidth: 1,
//             );
//           },
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           rightTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           topTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 30,
//               interval: data.length / 5,
//               getTitlesWidget: (value, meta) {
//                 final index = value.toInt();
//                 if (index >= 0 && index < data.length) {
//                   final date = DateTime.parse(data[index].timestamp);
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       '${date.month}/${date.day}',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 10,
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 50,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   '\$${value.toInt()}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 10,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         lineTouchData: LineTouchData(
//           enabled: true,
//           touchTooltipData: LineTouchTooltipData(
//             tooltipBgColor: const Color(0xFF1a1f3a),
//             tooltipRoundedRadius: 8,
//             getTooltipItems: (touchedSpots) {
//               return touchedSpots.map((spot) {
//                 final date = DateTime.parse(data[spot.x.toInt()].timestamp);
//                 return LineTooltipItem(
//                   '\$${spot.y.toStringAsFixed(2)}\n${date.month}/${date.day}/${date.year}',
//                   const TextStyle(
//                     color: Color(0xFF00d4aa),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 );
//               }).toList();
//             },
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//             spots: data.asMap().entries.map((entry) {
//               return FlSpot(entry.key.toDouble(), entry.value.price);
//             }).toList(),
//             isCurved: true,
//             gradient: const LinearGradient(
//               colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//             ),
//             barWidth: 3,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: false),
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF00d4aa).withOpacity(0.3),
//                   const Color(0xFF0099ff).withOpacity(0.05),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildLoadingChart() {
//     return Shimmer.fromColors(
//       baseColor: const Color(0xFF1a1f3a),
//       highlightColor: const Color(0xFF2a2f4a),
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1a1f3a),
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }

