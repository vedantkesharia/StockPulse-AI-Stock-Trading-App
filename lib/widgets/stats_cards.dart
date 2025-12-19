import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/stock_provider.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingData) {
          return _buildLoadingCards();
        }
        
        final stats = provider.marketStats;
        if (stats == null) return const SizedBox();
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Current Price',
                    '\$${stats.currentPrice.toStringAsFixed(2)}',
                    Icons.attach_money,
                    const Color(0xFF00d4aa),
                    null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '24h Change',
                    '${stats.changePercent >= 0 ? '+' : ''}${stats.changePercent.toStringAsFixed(2)}%',
                    stats.changePercent >= 0 
                        ? Icons.trending_up 
                        : Icons.trending_down,
                    stats.changePercent >= 0 
                        ? const Color(0xFF00d4aa) 
                        : const Color(0xFFff4444),
                    '\$${stats.changeAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Day High',
                    '\$${stats.dayHigh.toStringAsFixed(2)}',
                    Icons.arrow_upward,
                    const Color(0xFF0099ff),
                    null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Day Low',
                    '\$${stats.dayLow.toStringAsFixed(2)}',
                    Icons.arrow_downward,
                    const Color(0xFFff4444),
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildVolumeCard(context, stats.volume, stats.avgVolume),
          ],
        );
      },
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    String? subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildVolumeCard(BuildContext context, double volume, double avgVolume) {
    final volumeM = (volume / 1000000).toStringAsFixed(1);
    final avgVolumeM = (avgVolume / 1000000).toStringAsFixed(1);
    final isAboveAvg = volume > avgVolume;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${volumeM}M',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avg: ${avgVolumeM}M',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isAboveAvg 
                  ? const Color(0xFF00d4aa).withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isAboveAvg ? Icons.trending_up : Icons.trending_flat,
                  color: isAboveAvg ? const Color(0xFF00d4aa) : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isAboveAvg ? 'High' : 'Normal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAboveAvg ? const Color(0xFF00d4aa) : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingCards() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1a1f3a),
      highlightColor: const Color(0xFF2a2f4a),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLoadingCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildLoadingCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLoadingCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildLoadingCard()),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1f3a),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
