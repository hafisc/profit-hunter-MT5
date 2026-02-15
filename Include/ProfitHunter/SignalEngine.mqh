//+------------------------------------------------------------------+
//|                                                 SignalEngine.mqh |
//|                                          ProfitHunter EA         |
//|                                Strategy Logic: EMA 200 + RSI 14   |
//+------------------------------------------------------------------+
#property copyright "ProfitHunter EA"
#property version   "1.00"
#property strict

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| Class CSignalEngine                                               |
//| Purpose: Generate trading signals based on EMA and RSI            |
//+------------------------------------------------------------------+
class CSignalEngine
{
private:
   string            m_symbol;            // Trading symbol
   ENUM_TIMEFRAMES   m_timeframe;         // Trading timeframe
   int               m_emaPeriod;         // EMA period
   int               m_rsiPeriod;         // RSI period
   double            m_rsiLevel;          // RSI signal level
   
   // Indicator handles
   int               m_emaHandle;         // EMA indicator handle
   int               m_rsiHandle;         // RSI indicator handle
   
   // Previous RSI value for crossover detection
   double            m_previousRSI;       // Previous bar RSI value
   
public:
   //--- Constructor
   CSignalEngine(string symbol = NULL, 
                 ENUM_TIMEFRAMES timeframe = PERIOD_H1,
                 int emaPeriod = 200,
                 int rsiPeriod = 14,
                 double rsiLevel = 50.0)
   {
      m_symbol = (symbol == NULL) ? _Symbol : symbol;
      m_timeframe = timeframe;
      m_emaPeriod = emaPeriod;
      m_rsiPeriod = rsiPeriod;
      m_rsiLevel = rsiLevel;
      
      m_emaHandle = INVALID_HANDLE;
      m_rsiHandle = INVALID_HANDLE;
      m_previousRSI = 0.0;
      
      // Initialize indicators
      InitIndicators();
   }
   
   //--- Destructor
   ~CSignalEngine()
   {
      // Release indicator handles
      if(m_emaHandle != INVALID_HANDLE)
         IndicatorRelease(m_emaHandle);
      if(m_rsiHandle != INVALID_HANDLE)
         IndicatorRelease(m_rsiHandle);
   }
   
   //+------------------------------------------------------------------+
   //| Initialize indicator handles                                     |
   //+------------------------------------------------------------------+
   bool InitIndicators()
   {
      // Create EMA indicator
      m_emaHandle = iMA(m_symbol, m_timeframe, m_emaPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(m_emaHandle == INVALID_HANDLE)
      {
         Print("ERROR: Failed to create EMA indicator");
         return false;
      }
      
      // Create RSI indicator
      m_rsiHandle = iRSI(m_symbol, m_timeframe, m_rsiPeriod, PRICE_CLOSE);
      if(m_rsiHandle == INVALID_HANDLE)
      {
         Print("ERROR: Failed to create RSI indicator");
         return false;
      }
      
      return true;
   }
   
   //+------------------------------------------------------------------+
   //| Get trading signal                                               |
   //| Returns: SIGNAL_BUY, SIGNAL_SELL, or SIGNAL_NONE                 |
   //+------------------------------------------------------------------+
   ENUM_SIGNAL GetSignal()
   {
      // Check spread filter
      if(!CheckSpread())
      {
         return SIGNAL_NONE;
      }
      
      // Get indicator values
      double emaValue = GetEMAValue(1);      // Previous bar
      double rsiCurrent = GetRSIValue(1);    // Previous bar (closed)
      double rsiPrevious = GetRSIValue(2);   // Bar before previous
      
      if(emaValue == 0.0 || rsiCurrent == 0.0 || rsiPrevious == 0.0)
      {
         return SIGNAL_NONE;
      }
      
      // Get current price
      double close = iClose(m_symbol, m_timeframe, 1);
      
      // Buy Signal: Price > EMA 200 AND RSI crosses above 50
      if(close > emaValue && 
         rsiPrevious < m_rsiLevel && 
         rsiCurrent > m_rsiLevel)
      {
         Print("BUY SIGNAL: Price=", close, " EMA=", emaValue, 
               " RSI[1]=", rsiCurrent, " RSI[2]=", rsiPrevious);
         return SIGNAL_BUY;
      }
      
      // Sell Signal: Price < EMA 200 AND RSI crosses below 50
      if(close < emaValue && 
         rsiPrevious > m_rsiLevel && 
         rsiCurrent < m_rsiLevel)
      {
         Print("SELL SIGNAL: Price=", close, " EMA=", emaValue, 
               " RSI[1]=", rsiCurrent, " RSI[2]=", rsiPrevious);
         return SIGNAL_SELL;
      }
      
      return SIGNAL_NONE;
   }
   
   //+------------------------------------------------------------------+
   //| Check spread filter                                              |
   //+------------------------------------------------------------------+
   bool CheckSpread()
   {
      long spread = SymbolInfoInteger(m_symbol, SYMBOL_SPREAD);
      
      if(spread > MAX_SPREAD_POINTS)
      {
         Print("Spread too high: ", spread, " points (max: ", MAX_SPREAD_POINTS, ")");
         return false;
      }
      
      return true;
   }
   
   //+------------------------------------------------------------------+
   //| Get EMA value                                                    |
   //+------------------------------------------------------------------+
   double GetEMAValue(int shift)
   {
      double emaArray[];
      ArraySetAsSeries(emaArray, true);
      
      if(CopyBuffer(m_emaHandle, 0, shift, 1, emaArray) <= 0)
      {
         Print("ERROR: Failed to copy EMA data");
         return 0.0;
      }
      
      return emaArray[0];
   }
   
   //+------------------------------------------------------------------+
   //| Get RSI value                                                    |
   //+------------------------------------------------------------------+
   double GetRSIValue(int shift)
   {
      double rsiArray[];
      ArraySetAsSeries(rsiArray, true);
      
      if(CopyBuffer(m_rsiHandle, 0, shift, 1, rsiArray) <= 0)
      {
         Print("ERROR: Failed to copy RSI data");
         return 0.0;
      }
      
      return rsiArray[0];
   }
};
//+------------------------------------------------------------------+
