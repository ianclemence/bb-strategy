//+------------------------------------------------------------------+
//|                                             BB Test Strategy.mq4 |
//|                                                     Ian Clemence |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Ian Clemence"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

#include <CustomFunctions01.mqh>


int bandPeriod = 20;
int band1Std = 1;
int band2Std = 4;

input double riskPerTrade = 0.02;

int magicNB = 17171;
int orderID;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("");
   Alert("The EA just started");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert("The EA just closed");  
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(IsTradingAllowed())
   {      
      double lowerBand1 = iBands(NULL,0,bandPeriod,band1Std,0,PRICE_CLOSE,MODE_LOWER,0);
      double upperBand1 = iBands(NULL,0,bandPeriod,band1Std,0,PRICE_CLOSE,MODE_UPPER,0);
      double midBand = iBands(NULL,0,bandPeriod,band1Std,0,PRICE_CLOSE,MODE_MAIN,0);
      
      double lowerBand2 = iBands(NULL,0,bandPeriod,band2Std,0,PRICE_CLOSE,MODE_LOWER,0);
      double upperBand2 = iBands(NULL,0,bandPeriod,band2Std,0,PRICE_CLOSE,MODE_UPPER,0);
      
      if(!CheckOpenOrdersByMagicNB(magicNB)) //if no open orders, try to enter positions
      {
         if(Ask < lowerBand1)//buying
         {
            Alert("Price is below signalPrice, Sending buy order");
            double stopLossPrice = NormalizeDouble(lowerBand2,Digits);
            double takeProfitPrice = NormalizeDouble(midBand,Digits);
            Alert("Entry Price = " + Ask);
            Alert("Stop Loss Price = " + stopLossPrice);
            Alert("Take Profit Price = " + takeProfitPrice);
            
            //Position size
            double lotSize = OptimalLotSize(riskPerTrade, Ask, stopLossPrice);
            
            //Send buy order
            orderID = OrderSend(NULL, OP_BUYLIMIT, lotSize, Ask, 10, stopLossPrice, takeProfitPrice, NULL, magicNB);
            if(orderID < 0)
            {
               Alert("OrderSend failed with error #" + GetLastError());
            }
            else
            {
               Alert("OrderSend placed successfully");
            }
         }
         else if(Bid >upperBand1)//shorting
         {
            Alert("Price is above signalPrice, Sending short order");
            double stopLossPrice = NormalizeDouble(upperBand2,Digits);
            double takeProfitPrice = NormalizeDouble(midBand,Digits);
            Alert("Entry Price = " + Bid);
            Alert("Stop Loss Price = " + stopLossPrice);
            Alert("Take Profit Price = " + takeProfitPrice);
            
            //Position size
            double lotSize = OptimalLotSize(riskPerTrade, Bid, stopLossPrice);
      	  
      	   //Send short order
      	   orderID = OrderSend(NULL, OP_SELLLIMIT, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magicNB);
            if(orderID < 0)
            {
               Alert("OrderSend failed with error #" + GetLastError());
            }
         }
      }
      else // else if you already have open positions, update orders if required
      {      
         //Alert("Order already open");
         
         if(OrderSelect(orderID, SELECT_BY_TICKET) == true)
         {
            int orderType = OrderType(); // 0 = Long, 1 = Short
            
            double newExitPoint;
            
            if(orderType == 0)
            {
               newExitPoint = NormalizeDouble(lowerBand2, Digits);
            }
            else
            {
               newExitPoint = NormalizeDouble(upperBand2, Digits);
            }
            
            double currentMidLine = NormalizeDouble(midBand, Digits);
            
            double currentTakeProfit = OrderTakeProfit();
            double currentStopLoss = OrderStopLoss();
            
            if(currentTakeProfit != currentMidLine || currentStopLoss != newExitPoint)
            {
            
               OrderModify(orderID, OrderOpenPrice(), OrderStopLoss(), currentMidLine,0);
            
               /*
               bool Ans = OrderModify(orderID, OrderOpenPrice(), OrderStopLoss(), currentMidLine,0);
               
               if(Ans == true)
               {
                  Alert("Order modified: " + orderID);
               }
               */               
            }
         }
      
      }
   }
   
  }
//+------------------------------------------------------------------+
