//+------------------------------------------------------------------+
//|                                                 GalaxyTrader.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                                                                  |
//+------------------------------------------------------------------+
// Include
#include "Common.mq5"
#include "Common_Sell.mq5"
#include "Ichimoku.mq5"

// Parameters
input ENUM_TIMEFRAMES TIMEFRAME = PERIOD_H4;
input ENUM_TIMEFRAMES TP_TIMEFRAME = PERIOD_H1;
input int TIMER = 60;
input int POINT_GAP = 1000;
input int POINT_FAST = 300;
input double TP_POINT = 200;
input int MAX_TRADE = 3;

const string INPUT_SYMBOL = ChartSymbol();

// Ichimoku
double Tenkan_sen_Buffer[];
double Kijun_sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chikou_Span_Buffer[];
int Ichimoku_handle;
int TP_Ichimoku_handle;
// Number of copied values
const int amount = 30;
// Default number of copied values
const int default_amount = 27;

// Variables
// Is send Buy notification
bool isSendBuy = true;
// Is send Sell notification
bool isSendSell = true;
// Is send Take Profit notification
bool isSendTP = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SendNotification("Welcome to the Galaxy !!!\r\nSymbol: " + INPUT_SYMBOL);

//--- create timer
   EventSetTimer(TIMER * 60);

// Check if valid symbol
   if(!isValidSymbol()) {
      return(0);
   }

// Initialize Ichimoku
   Ichimoku_handle = iIchimoku(INPUT_SYMBOL, TIMEFRAME, 9, 26, 52);

// Initialize TP Ichimoku
   TP_Ichimoku_handle = iIchimoku(INPUT_SYMBOL, TP_TIMEFRAME, 9, 26, 52);

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
   EventKillTimer();
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
// Get ichimoku values
   FillArraysFromBuffers(Tenkan_sen_Buffer,
                         Kijun_sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         Ichimoku_handle);

// Processing Buy command
   ProcessBuy();

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_sen_Buffer,
                         Kijun_sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         Ichimoku_handle);

// Processing Sell command
   ProcessSell();
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
// Send TP Notification
   isSendTP = true;

// Send Buy notification
   isSendBuy = true;

// Send Sell notification
   isSendSell = true;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy Process                                                      |
//+------------------------------------------------------------------+
void ProcessBuy()
{
   if(0 == 0
// Is Send Buy Notification
      && isSendBuy
// If currently not trading
      && !IsSelling() && !IsBuying()
// If Chiukou-sen above Price
      && IsChikouAbovePrice()
// If Tenkan > Kijun
      && CurrentTenkan() > CurrentKijun()
// If Price Closed Above Cloud
      && IsPriceClosedAboveCloud()
// If Tick price near Cloud
      && IsPriceNearCloud()
// If Max Trade not Reach
      && IsMaxTrade()) {

      isSendBuy = false;
      SendNotification("Buy: " + INPUT_SYMBOL);
      Print("Galaxy Buy!!!\r\n" + INPUT_SYMBOL);
   }

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_sen_Buffer,
                         Kijun_sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         TP_Ichimoku_handle);

   if(isSendTP && IsBuying()) {
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

      // If Price touch Cloud
      if(Latest_Price.ask <= CurrentSenkouA()
         // If Cloud become Red cloud
         || CurrentSenkouA(default_amount - 1) < CurrentSenkouB(default_amount - 1)
         // If prev 3 closed price is going down
         || IsThreeFall()
         // If Tenkan Cross Kijun From Above
         || IsTenkanCrossKijunFromAbove()
         // If Price going down fast
         || IsPriceGoingDownFast()
         // If profit
         || IsProfit()
        ) {

         isSendTP = false;
         SendNotification("Take Profit: " + INPUT_SYMBOL);
         Print("Take Profit!!!\r\n" + INPUT_SYMBOL);
      }
   }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Sell Process                                                      |
//+------------------------------------------------------------------+
void ProcessSell()
{
   if(0 == 0
// Is Send Sell Notification
      && isSendSell
// If currently not trading
      && !IsSelling() && !IsBuying()
// If Chiukou-sen below Price
      && IsChikouBelowPrice()
// If Tenkan < Kijun
      && CurrentTenkan() < CurrentKijun()
// If Price Closed Below Cloud
      && IsPriceClosedBelowCloud()
// If Tick price near Cloud
      && IsPriceNearCloud_Sell()
// If Max Trade not Reach
      && IsMaxTrade()) {

      isSendSell = false;
      SendNotification("Sell: " + INPUT_SYMBOL);
      Print("Galaxy Sell!!!\r\n" + INPUT_SYMBOL);
   }

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_sen_Buffer,
                         Kijun_sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         TP_Ichimoku_handle);

   if(isSendTP && IsSelling()) {
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

      // If Price touch Cloud
      if(Latest_Price.ask >= CurrentSenkouB()
         // If Cloud become Green cloud
         || CurrentSenkouA(default_amount - 1) > CurrentSenkouB(default_amount - 1)
         // If prev 3 closed price is going up
         || IsThreeRise()
         // If Tenkan Cross Kijun From Above
         || IsTenkanCrossKijunFromBelow()
         // If Price going up fast
         || IsPriceGoingUpFast()
         // If profit
         || IsProfit_Sell()
        ) {

         isSendTP = false;
         SendNotification("Take Profit: " + INPUT_SYMBOL);
         Print("Take Profit!!!\r\n" + INPUT_SYMBOL);
      }
   }
}
//+------------------------------------------------------------------+
