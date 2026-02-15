//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                          ProfitHunter EA         |
//|                              Risk Management & Lot Size Calculator|
//+------------------------------------------------------------------+
#property copyright "ProfitHunter EA"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Class CRiskManager                                                |
//| Purpose: Calculate position size based on risk percentage         |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
   double            m_riskPercent;       // Risk percentage per trade
   string            m_symbol;            // Trading symbol
   
public:
   //--- Constructor
   CRiskManager(double riskPercent = 2.0, string symbol = NULL)
   {
      m_riskPercent = riskPercent;
      m_symbol = (symbol == NULL) ? _Symbol : symbol;
   }
   
   //--- Destructor
   ~CRiskManager() {}
   
   //+------------------------------------------------------------------+
   //| Calculate lot size based on account balance and risk            |
   //| Parameters:                                                       |
   //|   slPoints - Stop Loss distance in points                        |
   //| Returns: Calculated lot size (respecting broker limits)          |
   //+------------------------------------------------------------------+
   double GetLotSize(double slPoints)
   {
      if(slPoints <= 0)
      {
         Print("ERROR: Invalid SL points: ", slPoints);
         return 0.0;
      }
      
      // Get account balance
      double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      // Calculate risk amount in account currency
      double riskAmount = accountBalance * (m_riskPercent / 100.0);
      
      // Get symbol information
      double tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      
      if(tickSize == 0 || tickValue == 0 || point == 0)
      {
         Print("ERROR: Invalid symbol information");
         return 0.0;
      }
      
      // Calculate lot size
      // Risk Amount = Lot Size * SL in Points * Point Value
      double lotSize = riskAmount / (slPoints * point * tickValue / tickSize);
      
      // Get broker limits
      double minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
      
      // Normalize lot size to lot step
      lotSize = NormalizeLotSize(lotSize, minLot, maxLot, lotStep);
      
      return lotSize;
   }
   
   //+------------------------------------------------------------------+
   //| Normalize lot size to broker requirements                        |
   //+------------------------------------------------------------------+
   double NormalizeLotSize(double lots, double minLot, double maxLot, double lotStep)
   {
      // Round down to nearest lot step
      lots = MathFloor(lots / lotStep) * lotStep;
      
      // Ensure within broker limits
      if(lots < minLot) lots = minLot;
      if(lots > maxLot) lots = maxLot;
      
      // Round to 2 decimal places
      lots = NormalizeDouble(lots, 2);
      
      return lots;
   }
   
   //+------------------------------------------------------------------+
   //| Set risk percentage                                              |
   //+------------------------------------------------------------------+
   void SetRiskPercent(double riskPercent)
   {
      m_riskPercent = riskPercent;
   }
   
   //+------------------------------------------------------------------+
   //| Get current risk percentage                                      |
   //+------------------------------------------------------------------+
   double GetRiskPercent()
   {
      return m_riskPercent;
   }
};
//+------------------------------------------------------------------+
