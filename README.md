# 🎯 ProfitHunter EA - MetaTrader 5 Expert Advisor

[![MQL5](https://img.shields.io/badge/MQL5-Expert_Advisor-blue.svg)](https://www.mql5.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-orange.svg)](https://github.com/hafisc/profit-hunter-MT5)

A **robust, modular, and production-ready** Expert Advisor for MetaTrader 5 built with object-oriented programming principles. ProfitHunter EA implements a proven trend-following strategy using EMA and RSI indicators with intelligent risk management and dynamic trailing stop.

## ✨ Features

- 🏗️ **Modular Architecture** - Clean separation of concerns with dedicated classes
- 💰 **Smart Money Management** - Automatic position sizing based on account balance
- 📊 **EMA + RSI Strategy** - Combines trend filtering with momentum confirmation
- 🛡️ **Risk Protection** - Maximum 1 position at a time with spread filter
- 🔄 **Dynamic Trailing Stop** - Breakeven protection + intelligent profit trailing
- 🎯 **Production Ready** - Comprehensive error handling and logging
- ⚙️ **Highly Configurable** - Adjustable parameters via input settings

## 📋 Strategy Overview

### Trading Logic

| Component | Configuration |
|-----------|---------------|
| **Timeframe** | H1 (1 Hour) |
| **Trend Filter** | EMA 200 |
| **Entry Trigger** | RSI 14 crossover at level 50 |
| **Max Spread** | 50 points |

### Entry Conditions

**📈 Long (BUY) Signal:**
- Price is above EMA 200 (uptrend)
- RSI crosses above 50 (pullback recovery)
- Spread ≤ 50 points

**📉 Short (SELL) Signal:**
- Price is below EMA 200 (downtrend)
- RSI crosses below 50 (momentum reversal)
- Spread ≤ 50 points

### Risk & Trade Management

- **Risk per Trade:** 2% of account balance (default, configurable)
- **Initial Stop Loss:** 200 points (configurable)
- **Take Profit:** 400 points (configurable)
- **Trailing Stop:**
  - Activates when profit ≥ 200 points
  - Moves SL to breakeven first
  - Then trails price by 100 points

## 🚀 Installation

### Method 1: Direct Download

1. **Clone or download this repository:**
   ```bash
   git clone https://github.com/hafisc/profit-hunter-MT5.git
   ```

2. **Copy files to MT5 Data Folder:**
   - Open MetaTrader 5
   - Click `File` → `Open Data Folder`
   - Copy files to respective directories:
     ```
     📁 MQL5/
     ├── 📁 Include/ProfitHunter/
     │   ├── Defines.mqh
     │   ├── RiskManager.mqh
     │   ├── SignalEngine.mqh
     │   └── TradeManager.mqh
     └── 📁 Experts/
         └── ProfitHunter_EA.mq5
     ```

3. **Compile the EA:**
   - Open MetaEditor (F4 in MT5)
   - Navigate to `Experts/ProfitHunter_EA.mq5`
   - Press `F7` to compile
   - Verify no errors in the log

### Method 2: Git in MQL5 Folder

Navigate to your MT5 MQL5 folder and clone directly:
```bash
cd "C:\Users\YourUser\AppData\Roaming\MetaQuotes\Terminal\YOUR_MT5_ID\MQL5"
git clone https://github.com/hafisc/profit-hunter-MT5.git temp
xcopy temp\Include Include\ /E /I /Y
xcopy temp\Experts Experts\ /E /I /Y
rmdir /S /Q temp
```

## ⚙️ Configuration

### Input Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| **Risk Management** |
| `InpRiskPercent` | 2.0 | Risk per trade (% of balance) |
| **Strategy Parameters** |
| `InpEMAPeriod` | 200 | EMA period for trend filter |
| `InpRSIPeriod` | 14 | RSI period for entry signal |
| `InpRSILevel` | 50.0 | RSI crossover level |
| **Trade Settings** |
| `InpMagicNumber` | 123456 | Unique EA identifier |
| `InpTradeComment` | "ProfitHunter" | Comment for trades |
| `InpSlippage` | 10 | Allowed slippage (points) |
| **Stop Loss & Take Profit** |
| `InpStopLoss` | 200 | Initial stop loss (points) |
| `InpTakeProfit` | 400 | Take profit (points) |

## 📖 Usage

1. **Attach EA to Chart:**
   - Open H1 chart for your desired symbol (e.g., EURUSD)
   - Navigate to `Navigator` → `Expert Advisors`
   - Drag `ProfitHunter_EA` onto the chart

2. **Configure Settings:**
   - Adjust input parameters in the EA settings dialog
   - Start with default settings for initial testing
   - Consider reducing risk to 1% for conservative trading

3. **Enable Auto Trading:**
   - Click the "Auto Trading" button in MT5 toolbar (or press F7)
   - Verify the EA smiley face is active on chart
   - Check Expert tab in Terminal for EA messages

4. **Monitor Performance:**
   - Review trades in Account History
   - Monitor EA logs in Expert tab
   - Adjust parameters based on backtest results

## 📁 Project Structure

```
MQL5/
├── Include/ProfitHunter/
│   ├── Defines.mqh          # Enums, constants, configurations
│   ├── RiskManager.mqh      # Position sizing & money management
│   ├── SignalEngine.mqh     # EMA + RSI strategy logic
│   └── TradeManager.mqh     # Trade execution & trailing stop
└── Experts/
    └── ProfitHunter_EA.mq5  # Main EA entry point
```

### File Descriptions

- **`Defines.mqh`** - Central configuration with enums and constants
- **`RiskManager.mqh`** - Calculates lot size based on risk percentage and account balance
- **`SignalEngine.mqh`** - Generates BUY/SELL signals using EMA and RSI indicators
- **`TradeManager.mqh`** - Handles order execution and dynamic trailing stop management
- **`ProfitHunter_EA.mq5`** - Main file that orchestrates all components

## 🔧 Customization

The modular design makes it easy to customize:

### Change Strategy
Edit `SignalEngine.mqh` to implement different indicators or logic:
```cpp
// Example: Add MACD confirmation
int m_macdHandle;
// ... implement MACD logic
```

### Modify Risk Rules
Edit `RiskManager.mqh` to implement alternative position sizing:
```cpp
// Example: Implement Kelly Criterion
double GetKellyLotSize(double winRate, double avgWin, double avgLoss)
{
    // ... Kelly formula implementation
}
```

### Add Filters
Edit `SignalEngine.mqh` to add time or volatility filters:
```cpp
// Example: Add time-of-day filter
bool CheckTradingHours()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    return (dt.hour >= 8 && dt.hour <= 16); // Trade 8AM-4PM only
}
```

## 📊 Backtesting

Before live trading, always backtest:

1. **Open Strategy Tester** (Ctrl+R)
2. Select `ProfitHunter_EA`
3. Choose symbol (e.g., EURUSD)
4. Set timeframe to **H1**
5. Select date range (at least 1 year)
6. Use "Every tick based on real ticks" mode
7. Click **Start**

### Optimization Tips

- Test different EMA periods (150-250)
- Optimize RSI period (10-20)
- Adjust SL/TP ratio (1:1.5 to 1:3)
- Test on multiple symbols

## ⚠️ Disclaimer

> **IMPORTANT:** Trading foreign exchange on margin carries a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. The high degree of leverage can work against you as well as for you.
>
> This EA is provided for educational purposes. Always:
> - Test thoroughly on demo account first
> - Use proper risk management (max 1-2% per trade)
> - Never trade with money you cannot afford to lose
> - Understand the strategy before using it

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs via [Issues](https://github.com/hafisc/profit-hunter-MT5/issues)
- 💡 Suggest new features
- 🔧 Submit pull requests
- ⭐ Star this repo if you find it useful!

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

- **GitHub:** [@hafisc](https://github.com/hafisc)
- **Issues:** [GitHub Issues](https://github.com/hafisc/profit-hunter-MT5/issues)

## 🙏 Acknowledgments

- Built with MQL5 Standard Library
- Inspired by professional trading strategies
- Developed with object-oriented best practices

---

### 📈 Happy Trading! 🚀

*Remember: The best trade is the one you don't take if conditions aren't perfect.*

**Version 1.0.0** | Last Updated: February 2026
