import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_selector.dart';
import '../widgets/stats_cards.dart';
import '../widgets/price_chart.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/market_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStockData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<StockProvider>().refreshData(),
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MarketHeader(),
                  const SizedBox(height: 24),
                  const StockSelector(),
                  const SizedBox(height: 24),
                  const StatsCards(),
                  const SizedBox(height: 24),
                  const PriceChart(),
                  const SizedBox(height: 24),
                  const AIAnalysisCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }
  
  Widget _buildFloatingActions() {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.error != null)
              FloatingActionButton(
                heroTag: 'error',
                onPressed: provider.clearError,
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'refresh',
              onPressed: provider.isLoadingData 
                  ? null 
                  : () => provider.refreshData(),
              backgroundColor: Theme.of(context).primaryColor,
              child: provider.isLoadingData
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
            ),
          ],
        );
      },
    );
  }
}
