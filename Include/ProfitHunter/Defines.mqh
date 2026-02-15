//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                                          ProfitHunter EA Defines |
//|                                   Global Enums, Constants, Inputs|
//+------------------------------------------------------------------+
#property copyright "ProfitHunter EA"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL
{
   SIGNAL_NONE = 0,    // No signal
   SIGNAL_BUY  = 1,    // Buy signal
   SIGNAL_SELL = -1    // Sell signal
};

//+------------------------------------------------------------------+
//| Global Constants                                                  |
//+------------------------------------------------------------------+
#define EA_MAGIC_NUMBER    123456        // Magic number for this EA
#define MAX_SPREAD_POINTS  50            // Maximum allowed spread in points
#define BREAKEVEN_POINTS   200           // Profit in points to move to breakeven
#define TRAILING_POINTS    100           // Trailing stop distance in points

//+------------------------------------------------------------------+
//| Input Parameters Structure                                        |
//+------------------------------------------------------------------+
// These will be defined as input variables in the main EA file
// Documented here for reference

// Risk Management
// input double InpRiskPercent = 2.0;          // Risk per trade (%)

// Strategy Parameters
// input int    InpEMAPeriod = 200;            // EMA Period
// input int    InpRSIPeriod = 14;             // RSI Period
// input double InpRSILevel  = 50.0;           // RSI Signal Level

// Trade Management
// input int    InpMagicNumber = EA_MAGIC_NUMBER;  // Magic Number
// input string InpTradeComment = "ProfitHunter";  // Trade Comment

//+------------------------------------------------------------------+
