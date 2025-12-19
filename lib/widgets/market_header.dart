import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MarketHeader extends StatelessWidget {
  const MarketHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
                ).createShader(bounds),
                child: const Text(
                  'StockPulse',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00d4aa), Color(0xFF0099ff)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DefaultTextStyle(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          child: AnimatedTextKit(
            repeatForever: true,
            animatedTexts: [
              TypewriterAnimatedText(
                'Real-time market analysis powered by Gemini AI',
                speed: const Duration(milliseconds: 100),
              ),
              TypewriterAnimatedText(
                'Data synced with AWS cloud infrastructure',
                speed: const Duration(milliseconds: 100),
              ),
              TypewriterAnimatedText(
                'Professional-grade trading insights',
                speed: const Duration(milliseconds: 100),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

