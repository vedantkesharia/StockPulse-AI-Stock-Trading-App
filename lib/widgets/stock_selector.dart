import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';

class StockSelector extends StatelessWidget {
  const StockSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.availableStocks.length,
            itemBuilder: (context, index) {
              final stock = provider.availableStocks[index];
              final isSelected = stock.symbol == provider.selectedStock.symbol;
              
              return GestureDetector(
                onTap: () => provider.selectStock(stock),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(
                    right: 12,
                    left: index == 0 ? 0 : 0,
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF1a1f3a),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00d4aa).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stock.symbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (stock.description != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withOpacity(0.2) 
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            stock.description!,
                            style: TextStyle(
                              fontSize: 9,
                              color: isSelected ? Colors.white : Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/stock_provider.dart';

// class StockSelector extends StatelessWidget {
//   const StockSelector({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StockProvider>(
//       builder: (context, provider, _) {
//         return SizedBox(
//           height: 90,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: provider.availableStocks.length,
//             itemBuilder: (context, index) {
//               final stock = provider.availableStocks[index];
//               final isSelected = stock.symbol == provider.selectedStock.symbol;
              
//               return GestureDetector(
//                 onTap: () => provider.selectStock(stock),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   margin: const EdgeInsets.only(right: 12),
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   decoration: BoxDecoration(
//                     gradient: isSelected
//                         ? const LinearGradient(
//                             colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           )
//                         : null,
//                     color: isSelected ? null : const Color(0xFF1a1f3a),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: isSelected 
//                           ? Colors.transparent 
//                           : Colors.white.withOpacity(0.1),
//                       width: 1,
//                     ),
//                     boxShadow: isSelected
//                         ? [
//                             BoxShadow(
//                               color: const Color(0xFF00d4aa).withOpacity(0.3),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ]
//                         : null,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             stock.symbol,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: isSelected ? Colors.white : Colors.grey[400],
//                             ),
//                           ),
//                           if (isSelected) ...[
//                             const SizedBox(width: 8),
//                             const Icon(
//                               Icons.check_circle,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         stock.name,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: isSelected ? Colors.white70 : Colors.grey[600],
//                         ),
//                       ),
//                       if (stock.description != null) ...[
//                         const SizedBox(height: 2),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected 
//                                 ? Colors.white.withOpacity(0.2) 
//                                 : Colors.grey.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             stock.description!,
//                             style: TextStyle(
//                               fontSize: 9,
//                               color: isSelected ? Colors.white : Colors.grey[500],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

