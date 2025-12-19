import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/stock_provider.dart';

class AIAnalysisCard extends StatelessWidget {
  const AIAnalysisCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2d1b69).withOpacity(0.4),
                  const Color(0xFF0f1229),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7c3aed).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7c3aed).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                _buildContent(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(BuildContext context, StockProvider provider) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7c3aed).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gemini AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFa78bfa),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Powered by Google Gemini Pro',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildAnalyzeButton(provider),
      ],
    );
  }
  
  Widget _buildAnalyzeButton(StockProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7c3aed).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: provider.isLoadingAI ? null : provider.generateAIAnalysis,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isLoadingAI)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                const SizedBox(width: 6),
                Text(
                  provider.isLoadingAI ? 'Analyzing...' : 'Analyze',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, StockProvider provider) {
    if (provider.isLoadingAI) {
      return _buildLoadingState();
    }
    
    if (provider.aiAnalysis.isEmpty) {
      return _buildEmptyState(provider);
    }
    
    return _buildAnalysisResult(provider);
  }
  
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7c3aed).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFFa78bfa)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFa78bfa),
                  ),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Analyzing market trends...',
                        speed: const Duration(milliseconds: 50),
                      ),
                      TypewriterAnimatedText(
                        'Processing price data...',
                        speed: const Duration(milliseconds: 50),
                      ),
                      TypewriterAnimatedText(
                        'Generating insights...',
                        speed: const Duration(milliseconds: 50),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLoadingBars(),
        ],
      ),
    );
  }
  
  Widget _buildLoadingBars() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800 + (index * 200)),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(
                  Color.lerp(
                    const Color(0xFF7c3aed),
                    const Color(0xFFa78bfa),
                    value,
                  ),
                ),
                minHeight: 4,
              );
            },
          ),
        );
      }),
    );
  }
  
  Widget _buildEmptyState(StockProvider provider) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7c3aed).withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 44,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Get AI-Powered Insights',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Analyze" to get professional market analysis\nfor ${provider.selectedStock.symbol} powered by Gemini AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisResult(StockProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7c3aed).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI Generated',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                DateTime.now().toString().split('.')[0],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SelectableText(
            provider.aiAnalysis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.orange[300],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated analysis for educational purposes only. Not financial advice.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import '../providers/stock_provider.dart';

// class AIAnalysisCard extends StatelessWidget {
//   const AIAnalysisCard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StockProvider>(
//       builder: (context, provider, _) {
//         return Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 const Color(0xFF2d1b69).withOpacity(0.4),
//                 const Color(0xFF0f1229),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: const Color(0xFF7c3aed).withOpacity(0.3),
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF7c3aed).withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(context, provider),
//               const SizedBox(height: 20),
//               _buildContent(context, provider),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildHeader(BuildContext context, StockProvider provider) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF7c3aed).withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.psychology,
//             color: Colors.white,
//             size: 24,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Gemini AI Analysis',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Container(
//                     width: 6,
//                     height: 6,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFa78bfa),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Powered by Google Gemini Pro',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         _buildAnalyzeButton(provider),
//       ],
//     );
//   }
  
//   Widget _buildAnalyzeButton(StockProvider provider) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF7c3aed).withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: provider.isLoadingAI ? null : provider.generateAIAnalysis,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               children: [
//                 if (provider.isLoadingAI)
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation(Colors.white),
//                     ),
//                   )
//                 else
//                   const Icon(
//                     Icons.auto_awesome,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                 const SizedBox(width: 8),
//                 Text(
//                   provider.isLoadingAI ? 'Analyzing...' : 'Analyze',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildContent(BuildContext context, StockProvider provider) {
//     if (provider.isLoadingAI) {
//       return _buildLoadingState();
//     }
    
//     if (provider.aiAnalysis.isEmpty) {
//       return _buildEmptyState(provider);
//     }
    
//     return _buildAnalysisResult(provider);
//   }
  
//   Widget _buildLoadingState() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xFF7c3aed).withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation(Color(0xFFa78bfa)),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: DefaultTextStyle(
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFFa78bfa),
//                   ),
//                   child: AnimatedTextKit(
//                     repeatForever: true,
//                     animatedTexts: [
//                       TypewriterAnimatedText(
//                         'Analyzing market trends...',
//                         speed: const Duration(milliseconds: 50),
//                       ),
//                       TypewriterAnimatedText(
//                         'Processing price data...',
//                         speed: const Duration(milliseconds: 50),
//                       ),
//                       TypewriterAnimatedText(
//                         'Generating insights...',
//                         speed: const Duration(milliseconds: 50),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildLoadingBars(),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildLoadingBars() {
//     return Column(
//       children: List.generate(3, (index) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0.0, end: 1.0),
//             duration: Duration(milliseconds: 800 + (index * 200)),
//             builder: (context, value, child) {
//               return LinearProgressIndicator(
//                 value: value,
//                 backgroundColor: Colors.white.withOpacity(0.05),
//                 valueColor: AlwaysStoppedAnimation(
//                   Color.lerp(
//                     const Color(0xFF7c3aed),
//                     const Color(0xFFa78bfa),
//                     value,
//                   ),
//                 ),
//                 minHeight: 4,
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
  
//   Widget _buildEmptyState(StockProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.03),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xFF7c3aed).withOpacity(0.1),
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.lightbulb_outline,
//             size: 48,
//             color: Colors.grey[700],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Get AI-Powered Insights',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[400],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Click "Analyze" to get professional market analysis\nfor ${provider.selectedStock.symbol} powered by Gemini AI',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey[600],
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildAnalysisResult(StockProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xFF7c3aed).withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
//                   ),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.verified,
//                       color: Colors.white,
//                       size: 14,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'AI Generated',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 DateTime.now().toString().split('.')[0],
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SelectableText(
//             provider.aiAnalysis,
//             style: const TextStyle(
//               fontSize: 14,
//               height: 1.7,
//               color: Colors.white,
//               letterSpacing: 0.2,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.orange.withOpacity(0.3),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   size: 16,
//                   color: Colors.orange[300],
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'AI-generated analysis for educational purposes only. Not financial advice.',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.orange[300],
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
