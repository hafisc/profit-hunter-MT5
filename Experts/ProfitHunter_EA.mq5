//+------------------------------------------------------------------+
//|                                              ProfitHunter_EA.mq5 |
//|                                          ProfitHunter EA v1.0    |
//|                    Modular EA: EMA 200 + RSI 14 Strategy (H1)    |
//+------------------------------------------------------------------+
#property copyright "ProfitHunter EA"
#property version   "1.00"
#property description "Robust modular EA using EMA trend filter and RSI signals"


// Include custom classes
#include <ProfitHunter\Defines.mqh>
#include <ProfitHunter\RiskManager.mqh>
#include <ProfitHunter\SignalEngine.mqh>
#include <ProfitHunter\TradeManager.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
input group "=== Risk Management ==="
input double InpRiskPercent = 2.0;           // Risk per trade (%)

input group "=== Strategy Parameters ==="
input int    InpEMAPeriod = 200;             // EMA Period
input int    InpRSIPeriod = 14;              // RSI Period
input double InpRSILevel  = 50.0;            // RSI Signal Level

input group "=== Trade Settings ==="
input int    InpMagicNumber = EA_MAGIC_NUMBER;  // Magic Number
input string InpTradeComment = "ProfitHunter";  // Trade Comment
input int    InpSlippage = 10;               // Allowed Slippage (points)

input group "=== Stop Loss & Take Profit ==="
input int    InpStopLoss = 200;              // Initial Stop Loss (points, 0=none)
input int    InpTakeProfit = 400;            // Take Profit (points, 0=none)

//+------------------------------------------------------------------+
//| Global Objects                                                    |
//+------------------------------------------------------------------+
CRiskManager      *g_riskManager;     // Risk management object
CSignalEngine     *g_signalEngine;    // Signal generation object
CTradeManager     *g_tradeManager;    // Trade execution object

// Variables for new bar detection
datetime          g_lastBarTime = 0;  // Last bar time

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("========================================");
   Print("ProfitHunter EA v1.0 Initializing...");
   Print("========================================");
   
   // Validate inputs
   if(InpRiskPercent <= 0 || InpRiskPercent > 100)
   {
      Print("ERROR: Invalid Risk Percent: ", InpRiskPercent);
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(InpEMAPeriod <= 0 || InpRSIPeriod <= 0)
   {
      Print("ERROR: Invalid indicator periods");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Initialize Risk Manager
   g_riskManager = new CRiskManager(InpRiskPercent, _Symbol);
   if(g_riskManager == NULL)
   {
      Print("ERROR: Failed to initialize Risk Manager");
      return INIT_FAILED;
   }
   
   // Initialize Signal Engine
   g_signalEngine = new CSignalEngine(_Symbol, PERIOD_H1, InpEMAPeriod, InpRSIPeriod, InpRSILevel);
   if(g_signalEngine == NULL)
   {
      Print("ERROR: Failed to initialize Signal Engine");
      return INIT_FAILED;
   }
   
   // Initialize Trade Manager
   g_tradeManager = new CTradeManager(_Symbol, InpMagicNumber, InpTradeComment, InpSlippage);
   if(g_tradeManager == NULL)
   {
      Print("ERROR: Failed to initialize Trade Manager");
      return INIT_FAILED;
   }
   
   // Initialize last bar time
   g_lastBarTime = iTime(_Symbol, PERIOD_H1, 0);
   
   Print("Risk per trade: ", InpRiskPercent, "%");
   Print("Strategy: EMA(", InpEMAPeriod, ") + RSI(", InpRSIPeriod, ")");
   Print("Timeframe: H1");
   Print("Magic Number: ", InpMagicNumber);
   Print("========================================");
   Print("ProfitHunter EA Initialized Successfully!");
   Print("========================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("========================================");
   Print("ProfitHunter EA Shutting Down...");
   Print("Reason: ", reason);
   Print("========================================");
   
   // Clean up objects
   if(g_riskManager != NULL)
   {
      delete g_riskManager;
      g_riskManager = NULL;
   }
   
   if(g_signalEngine != NULL)
   {
      delete g_signalEngine;
      g_signalEngine = NULL;
   }
   
   if(g_tradeManager != NULL)
   {
      delete g_tradeManager;
      g_tradeManager = NULL;
   }
   
   Print("ProfitHunter EA stopped successfully.");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if we have a new bar (to avoid tick spamming)
   if(!IsNewBar())
   {
      // Even if not a new bar, manage trailing stop on every tick
      g_tradeManager.ManageTrailingStop();
      return;
   }
   
   // Update last bar time
   g_lastBarTime = iTime(_Symbol, PERIOD_H1, 0);
   
   // Check if we already have an open position
   if(g_tradeManager.HasOpenPosition())
   {
      // Manage trailing stop
      g_tradeManager.ManageTrailingStop();
      return;  // Only 1 position at a time
   }
   
   // Get trading signal
   ENUM_SIGNAL signal = g_signalEngine.GetSignal();
   
   // Execute trades based on signal
   if(signal == SIGNAL_BUY)
   {
      ExecuteBuy();
   }
   else if(signal == SIGNAL_SELL)
   {
      ExecuteSell();
   }
}

//+------------------------------------------------------------------+
//| Check if there is a new bar                                      |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(_Symbol, PERIOD_H1, 0);
   
   if(currentBarTime != g_lastBarTime)
   {
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Execute Buy Order                                                |
//+------------------------------------------------------------------+
void ExecuteBuy()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Calculate SL and TP
   double sl = 0;
   double tp = 0;
   
   if(InpStopLoss > 0)
      sl = ask - (InpStopLoss * point);
   
   if(InpTakeProfit > 0)
      tp = ask + (InpTakeProfit * point);
   
   // Calculate lot size based on SL
   double lotSize = 0.0;
   
   if(InpStopLoss > 0)
   {
      lotSize = g_riskManager.GetLotSize(InpStopLoss);
   }
   else
   {
      // If no SL, use fixed lot or default calculation
      lotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      Print("WARNING: No Stop Loss set, using minimum lot size");
   }
   
   if(lotSize <= 0)
   {
      Print("ERROR: Invalid lot size calculated: ", lotSize);
      return;
   }
   
   // Normalize prices
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   
   // Open buy position
   Print("Opening BUY position: Lots=", lotSize, " SL=", sl, " TP=", tp);
   g_tradeManager.OpenBuy(lotSize, sl, tp);
}

//+------------------------------------------------------------------+
//| Execute Sell Order                                               |
//+------------------------------------------------------------------+
void ExecuteSell()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Calculate SL and TP
   double sl = 0;
   double tp = 0;
   
   if(InpStopLoss > 0)
      sl = bid + (InpStopLoss * point);
   
   if(InpTakeProfit > 0)
      tp = bid - (InpTakeProfit * point);
   
   // Calculate lot size based on SL
   double lotSize = 0.0;
   
   if(InpStopLoss > 0)
   {
      lotSize = g_riskManager.GetLotSize(InpStopLoss);
   }
   else
   {
      // If no SL, use fixed lot or default calculation
      lotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      Print("WARNING: No Stop Loss set, using minimum lot size");
   }
   
   if(lotSize <= 0)
   {
      Print("ERROR: Invalid lot size calculated: ", lotSize);
      return;
   }
   
   // Normalize prices
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   
   // Open sell position
   Print("Opening SELL position: Lots=", lotSize, " SL=", sl, " TP=", tp);
   g_tradeManager.OpenSell(lotSize, sl, tp);
}
//+------------------------------------------------------------------+
