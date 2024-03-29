//+------------------------------------------------------------------+
//|                                              CustomFunctions.mqh |
//|                                                     Ian Clemence |
//|                   https://github.com/ianclemence/bb-strategy |
//+------------------------------------------------------------------+
#property copyright "Ian Clemence"
#property link      "https://github.com/ianclemence/bb-strategy"
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



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue()
  {
   if(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) >= 4)
     {
      return 0.0001;
     }
   else
     {
      return 0.01;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossPrice(bool bIsLongPosition, double entryPrice, int maxLossInPips)
  {
   double stopLossPrice;
   if(bIsLongPosition)
     {
      stopLossPrice = entryPrice - maxLossInPips * 0.0001;
     }
   else
     {
      stopLossPrice = entryPrice + maxLossInPips * 0.0001;
     }
   return stopLossPrice;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
  {
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      PrintFormat("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
                  ".\n Perhaps an investor password has been used to connect to the trading account.",
                  "\n Check the terminal journal for the following entry:",
                  "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return false;
     }
   else
     {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         PrintFormat("Check if automated trading is allowed in the terminal settings!");
         return false;
        }
      else
        {
         return true;
        }

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
  {
//default lotsize

   double lotSize = 0.01;

   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();

   double accEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   PrintFormat("accEquity: " + accEquity);

   double contractSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
   PrintFormat("contractSize: " + contractSize);

   double tickValue = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);

   if(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) <= 3)
     {
      tickValue = tickValue /100;
     }

   PrintFormat("tickValue: " + tickValue);

   double maxLossDollar = accEquity * maxRiskPrc;
   PrintFormat("maxLossDollar: " + maxLossDollar);

   double maxLossInQuoteCurr = maxLossDollar / tickValue;
   PrintFormat("maxLossInQuoteCurr: " + maxLossInQuoteCurr);

   double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * GetPipValue())/contractSize,2);

   if(optimalLotSize > 0)
     {
      return optimalLotSize;
     }
   else
     {
      return lotSize;
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckIfOpenPositionsByMagicNumber(int magicNumber)
  {
   int positions = 0;
   int openOrders = 0;

   for(int v = PositionsTotal() - 1; v >= 0; v--)
     {
      ulong positionTicket = PositionGetTicket(v);
      ulong  positionMagic=PositionGetInteger(POSITION_MAGIC);
      string positionSymbol = PositionGetString(POSITION_SYMBOL);

      if(PositionSelectByTicket(positionTicket))
        {
         if(positionMagic == magicNumber && positionSymbol == _Symbol)
           {
            positions++;
           }
        }
     }

   for(int v = OrdersTotal() - 1; v >= 0; v--)
     {
      ulong orderTicket = OrderGetTicket(v);
      ulong  orderMagic= OrderGetInteger(ORDER_MAGIC);
      string orderSymbol = OrderGetString(ORDER_SYMBOL);

      if(OrderSelect(orderTicket))
        {
         if(orderMagic == magicNumber && orderSymbol == _Symbol)
           {
            openOrders++;
           }
        }
     }

   if(openOrders == 2 || positions >= 2)
     {
      return true; // you cannot trade
     }

   return false; // you can trade
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint SendOrder(long const magic_number, string symbol, double lotSize, double stopLossPrice, double takeProfitPrice, ENUM_ORDER_TYPE orderType, double price)
  {
//--- prepare a request
   MqlTradeRequest request= {};
   request.action = TRADE_ACTION_PENDING;
   request.magic = magic_number;
   request.symbol = symbol;
   request.volume = lotSize;
   request.sl = stopLossPrice;
   request.tp = takeProfitPrice;
//--- form the order type
   request.type = orderType;
//--- form the price for the pending order
   request.price = price;
//--- send a trade request
   MqlTradeResult result= {};
   OrderSend(request,result);
//--- write the server reply to log
   PrintFormat(__FUNCTION__,":",result.comment);
   if(result.retcode==10016)
      PrintFormat(result.bid,result.ask,result.price);
//--- return code of the trade server reply
   return result.retcode;
  }
//+------------------------------------------------------------------+
