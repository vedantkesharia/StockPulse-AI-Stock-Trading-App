# 📈 StockPulse - AI Stock Trading Dashboard

A sophisticated Flutter-based stock trading dashboard powered by Google Gemini AI and AWS cloud infrastructure. Get real-time market data, professional-grade analytics, and AI-powered insights for informed trading decisions.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![AWS](https://img.shields.io/badge/AWS-Lambda-FF9900?logo=amazon-aws)
![Gemini AI](https://img.shields.io/badge/Gemini-AI-4285F4?logo=google)

## ✨ Features

### 📊 Real-Time Market Data
- Live stock prices from major tech companies (AAPL, GOOGL, MSFT, TSLA, AMZN, NVDA, META)
- Real-time price updates via AWS Lambda integration
- Historical price charts with multiple timeframes (1D, 1W, 1M, 3M, 1Y)
- Daily high/low tracking and volume analysis

### 🤖 AI-Powered Analysis
- Market sentiment analysis powered by Google Gemini Pro
- Intelligent trading insights and recommendations
- Pattern recognition and trend prediction
- Professional-grade market analysis at your fingertips

### 📈 Interactive Charts
- Beautiful, responsive price charts using FL Chart
- Multiple timeframe support for detailed analysis
- Touch interactions for precise data points
- Gradient visualizations for better readability

### 💹 Market Statistics
- Current price with 24h change percentage
- Day high and low tracking
- Trading volume indicators
- Average volume comparison

### 🎨 Modern UI/UX
- Dark theme optimized for extended viewing
- Smooth animations and transitions
- Shimmer loading effects
- Gradient accents and glassmorphism design
- Responsive layout for all screen sizes

## 🛠️ Technologies Used

### Frontend
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart 3.0+** - Programming language
- **Provider** - State management
- **FL Chart** - Beautiful chart library
- **Animated Text Kit** - Text animations
- **Shimmer** - Loading animations

### Backend & APIs
- **AWS Lambda** - Serverless compute for stock data processing
- **API Gateway** - RESTful API management
- **Google Gemini AI** - Advanced AI analysis
- **Alpha Vantage API** - Real-time stock market data

### Architecture
- **MVVM Pattern** - Clean architecture
- **Provider Pattern** - State management
- **Service Layer** - API abstraction
- **Environment Variables** - Secure configuration

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vedantkesharia/StockPulse-AI-Stock-Trading-App.git
   cd ai-stock-dashboard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

4. **Configure API keys**
   
   Edit `.env` and add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   AWS_LAMBDA_URL=your_aws_lambda_url_here
   AWS_API_KEY=your_aws_api_key_here
   ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key_here
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Keys Setup

### Google Gemini AI
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key to your `.env` file

### Alpha Vantage
1. Visit [Alpha Vantage](https://www.alphavantage.co/support/#api-key)
2. Enter your email and click "GET FREE API KEY"
3. Copy the key to your `.env` file
4. **Note:** Free tier allows 5 API calls per minute, 500 per day

### AWS Lambda Setup
1. Create an AWS account at [AWS Console](https://console.aws.amazon.com)
2. Navigate to AWS Lambda
3. Create a new function using the code in `aws/lambda_function.py`
4. Set up API Gateway to expose your Lambda function
5. Add the API Gateway URL and API key to your `.env` file

**Environment Variable:**
- Add `ALPHA_VANTAGE_API_KEY` to Lambda environment variables

## 📁 Project Structure

```
lib/
├── config/
│   └── app_config.dart          # Environment configuration
├── models/
│   ├── stock.dart               # Stock data models
│   └── stock.g.dart             # Generated JSON serialization
├── providers/
│   └── stock_provider.dart      # State management
├── screens/
│   └── dashboard_screen.dart    # Main dashboard UI
├── services/
│   ├── aws_service.dart         # AWS Lambda integration
│   └── gemini_service.dart      # Gemini AI integration
├── utils/
│   └── mock_data_generator.dart # Mock data for testing
├── widgets/
│   ├── ai_analysis_card.dart    # AI insights widget
│   ├── market_header.dart       # App header
│   ├── price_chart.dart         # Interactive chart
│   ├── stats_cards.dart         # Market statistics
│   └── stock_selector.dart      # Stock selection carousel
└── main.dart                    # App entry point

aws/
└── lambda_function.py           # AWS Lambda function

.env.example                     # Environment template
.env                            # Your actual API keys (git-ignored)
```

## ⚙️ Configuration

### Feature Flags

Configure app behavior in `.env`:

```env
# Enable/disable AWS integration
ENABLE_AWS_INTEGRATION=true

# Enable/disable Gemini AI features
ENABLE_GEMINI_AI=true

# Use mock data for testing (no API calls)
USE_MOCK_DATA=false

# Allow fallback to mock data if APIs fail
ALLOW_MOCK_FALLBACK=false
```

## 🔧 Development

### Running in Debug Mode
```bash
flutter run --debug
```

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Running Tests
```bash
flutter test
```

## 📱 Supported Platforms

- ✅ Android (6.0+)
- ✅ iOS (11.0+)
- ✅ Web (Beta)
- ✅ Windows (Beta)
- ✅ macOS (Beta)
- ✅ Linux (Beta)

## 🎯 Roadmap

- [ ] Multiple watchlists
- [ ] Portfolio tracking
- [ ] Push notifications for price alerts
- [ ] Historical performance analytics
- [ ] More chart indicators (RSI, MACD, etc.)
- [ ] News integration
- [ ] Social sentiment analysis
- [ ] Dark/Light theme toggle
- [ ] Multi-language support

## 🐛 Known Issues

- Alpha Vantage free tier has rate limits (5 calls/min)
- AWS Lambda cold start may cause initial load delays
- Chart animations may lag on low-end devices

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Google Gemini](https://ai.google.dev) for AI capabilities
- [Alpha Vantage](https://www.alphavantage.co) for stock market data
- [FL Chart](https://github.com/imaNNeo/fl_chart) for beautiful charts

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Made with ❤️ using Flutter**

**⭐ Star this repo if you find it helpful!**
