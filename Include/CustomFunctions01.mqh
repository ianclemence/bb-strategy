//+------------------------------------------------------------------+
//|                                            CustomFunctions01.mqh |
//|                                                     Ian Clemence |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Ian Clemence"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

double GetPipValue()
{
   if(_Digits >= 4)
   {
      return 0.0001;
   }
   else
   {
      return 0.01;
   }
}


double CalculateTakeProfit(bool isLong, double entryPrice, int pips)
{
   double takeProfit;
   if(isLong)
   {
      takeProfit = entryPrice + pips * GetPipValue();
   }
   else
   {
      takeProfit = entryPrice - pips * GetPipValue();
   }
   
   return takeProfit;
}


double CalculateStopLoss(bool isLong, double entryPrice, int pips)
{
   double stopLoss;
   if(isLong)
   {
      stopLoss = entryPrice - pips * GetPipValue();
   }
   else
   {
      stopLoss = entryPrice + pips * GetPipValue();
   }
   
   return stopLoss;
}


bool IsTradingAllowed()
{
   if(!IsTradeAllowed())
   {
      Print("Expert Advisor is NOT allowed to trade. Kindly turn ON AutoTrading");
      return false;      
   }
   
   if(!IsTradeAllowed(Symbol(), TimeCurrent()))
   {
      Print("Trading NOT allowed for specific Symbol and Time");
      return false;
   }
   
   return true;      
}


double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
{   
   double accEquity = AccountEquity(); 
   Print("Account Equity: " + accEquity);
   
   double lotSize = MarketInfo(NULL, MODE_LOTSIZE);  
   Print("Lot Size: " + lotSize);
   
   double tickValue = MarketInfo(NULL, MODE_TICKVALUE); 
   
   //JPY fix
   if(Digits <= 3)
   {
      tickValue = tickValue / 100;
   } 
   Print("Tick Value: " + tickValue);
   
   double maxLossDollar = accEquity * maxRiskPrc;
   Print("Max Loss per Trade: " + maxLossDollar);
   
   double maxLossInQuoteCurr = maxLossDollar / tickValue;
   Print("Max Loss in Quote Currency: " + maxLossInQuoteCurr);
   
   double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr / (maxLossInPips * GetPipValue()) / lotSize, 2);
   
   return optimalLotSize;
}


double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs(entryPrice - stopLoss) / GetPipValue();
   
   double optLotSize = OptimalLotSize(maxRiskPrc, maxLossInPips);
   
   return optLotSize;
}


bool CheckOpenOrdersByMagicNB(int magicNB)
{
   int openOrders = OrdersTotal();
   
   for(int i = 0; i < openOrders; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == true)
      {
         if(OrderMagicNumber() == magicNB) return true;
      }
   }
   
   return false;
}
