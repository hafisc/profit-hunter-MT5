//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                                          ProfitHunter EA         |
//|                        Trade Execution & Trailing Stop Management |
//+------------------------------------------------------------------+
#property copyright "ProfitHunter EA"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include "Defines.mqh"

//+------------------------------------------------------------------+
//| Class CTradeManager                                               |
//| Purpose: Execute trades and manage trailing stop                  |
//+------------------------------------------------------------------+
class CTradeManager
{
private:
   CTrade            m_trade;             // Trade execution object
   string            m_symbol;            // Trading symbol
   int               m_magicNumber;       // Magic number
   string            m_comment;           // Trade comment
   ulong             m_deviation;         // Allowed slippage
   
public:
   //--- Constructor
   CTradeManager(string symbol = NULL, 
                 int magicNumber = EA_MAGIC_NUMBER,
                 string comment = "ProfitHunter",
                 ulong deviation = 10)
   {
      m_symbol = (symbol == NULL) ? _Symbol : symbol;
      m_magicNumber = magicNumber;
      m_comment = comment;
      m_deviation = deviation;
      
      // Configure CTrade object
      m_trade.SetExpertMagicNumber(m_magicNumber);
      m_trade.SetDeviationInPoints(m_deviation);
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
      m_trade.SetAsyncMode(false);
   }
   
   //--- Destructor
   ~CTradeManager() {}
   
   //+------------------------------------------------------------------+
   //| Check if position exists for this symbol and magic               |
   //+------------------------------------------------------------------+
   bool HasOpenPosition()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket <= 0) continue;
         
         if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
            PositionGetInteger(POSITION_MAGIC) == m_magicNumber)
         {
            return true;
         }
      }
      return false;
   }
   
   //+------------------------------------------------------------------+
   //| Open Buy position                                                |
   //+------------------------------------------------------------------+
   bool OpenBuy(double lotSize, double sl = 0, double tp = 0)
   {
      double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      
      if(!m_trade.Buy(lotSize, m_symbol, ask, sl, tp, m_comment))
      {
         Print("ERROR: Buy order failed. Error: ", GetLastError());
         Print("Result: ", m_trade.ResultRetcode(), " - ", m_trade.ResultRetcodeDescription());
         return false;
      }
      
      Print("BUY order opened successfully. Ticket: ", m_trade.ResultOrder(), 
            " Lots: ", lotSize, " Price: ", ask);
      return true;
   }
   
   //+------------------------------------------------------------------+
   //| Open Sell position                                               |
   //+------------------------------------------------------------------+
   bool OpenSell(double lotSize, double sl = 0, double tp = 0)
   {
      double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      
      if(!m_trade.Sell(lotSize, m_symbol, bid, sl, tp, m_comment))
      {
         Print("ERROR: Sell order failed. Error: ", GetLastError());
         Print("Result: ", m_trade.ResultRetcode(), " - ", m_trade.ResultRetcodeDescription());
         return false;
      }
      
      Print("SELL order opened successfully. Ticket: ", m_trade.ResultOrder(), 
            " Lots: ", lotSize, " Price: ", bid);
      return true;
   }
   
   //+------------------------------------------------------------------+
   //| Manage trailing stop for open positions                          |
   //| Logic:                                                           |
   //| 1. If profit > 200 points, move SL to breakeven                  |
   //| 2. Continue trailing by 100 points                               |
   //+------------------------------------------------------------------+
   void ManageTrailingStop()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket <= 0) continue;
         
         // Check if position belongs to this EA
         if(PositionGetString(POSITION_SYMBOL) != m_symbol ||
            PositionGetInteger(POSITION_MAGIC) != m_magicNumber)
            continue;
         
         double currentSL = PositionGetDouble(POSITION_SL);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         
         double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
         double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
         
         double newSL = currentSL;
         bool modifyNeeded = false;
         
         if(posType == POSITION_TYPE_BUY)
         {
            double profitPoints = (bid - openPrice) / point;
            
            // Move to breakeven if profit > 200 points
            if(profitPoints >= BREAKEVEN_POINTS)
            {
               double breakEvenSL = openPrice;
               
               // Then trail by 100 points
               double trailingSL = bid - (TRAILING_POINTS * point);
               
               // Use the higher of breakeven or trailing SL
               newSL = MathMax(breakEvenSL, trailingSL);
               
               // Only modify if new SL is higher than current SL
               if(newSL > currentSL || currentSL == 0)
               {
                  modifyNeeded = true;
               }
            }
         }
         else if(posType == POSITION_TYPE_SELL)
         {
            double profitPoints = (openPrice - ask) / point;
            
            // Move to breakeven if profit > 200 points
            if(profitPoints >= BREAKEVEN_POINTS)
            {
               double breakEvenSL = openPrice;
               
               // Then trail by 100 points
               double trailingSL = ask + (TRAILING_POINTS * point);
               
               // Use the lower of breakeven or trailing SL
               if(currentSL == 0)
                  newSL = trailingSL;
               else
                  newSL = MathMin(breakEvenSL, trailingSL);
               
               // Only modify if new SL is lower than current SL (or not set)
               if(newSL < currentSL || currentSL == 0)
               {
                  modifyNeeded = true;
               }
            }
         }
         
         // Modify position if needed
         if(modifyNeeded)
         {
            double tp = PositionGetDouble(POSITION_TP);
            
            if(m_trade.PositionModify(ticket, newSL, tp))
            {
               Print("Trailing stop updated. Ticket: ", ticket, " New SL: ", newSL);
            }
            else
            {
               Print("ERROR: Failed to modify position. Error: ", GetLastError());
            }
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //| Get current position profit in points                            |
   //+------------------------------------------------------------------+
   double GetPositionProfitPoints()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket <= 0) continue;
         
         if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
            PositionGetInteger(POSITION_MAGIC) == m_magicNumber)
         {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
            double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            if(posType == POSITION_TYPE_BUY)
               return (currentPrice - openPrice) / point;
            else
               return (openPrice - currentPrice) / point;
         }
      }
      return 0.0;
   }
};
//+------------------------------------------------------------------+
