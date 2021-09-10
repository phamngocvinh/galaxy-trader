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
input int TIMER = 60;
input int POINT_GAP = 1000;

const string INPUT_SYMBOL = ChartSymbol();

// Ichimoku
double Tenkan_sen_Buffer[];
double Kijun_sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chikou_Span_Buffer[];
int Ichimoku_handle;
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
// If not currently buying
      && !IsBuying()
// If Chiukou-sen above Price
      && IsChikouAbovePrice()
// If Tenkan > Kijun
      && CurrentTenkan() > CurrentKijun()
// If Price Closed Above Cloud
      && IsPriceClosedAboveCloud()
// If Tick price near Cloud
      && IsPriceNearCloud()) {

      isSendBuy = false;
      SendNotification("Buy: " + INPUT_SYMBOL);
      Print("Galaxy Buy!!!\r\n" + INPUT_SYMBOL);
   }

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
// If not currently selling
      && !IsSelling()
// If Chiukou-sen below Price
      && IsChikouBelowPrice()
// If Tenkan < Kijun
      && CurrentTenkan() < CurrentKijun()
// If Price Closed Below Cloud
      && IsPriceClosedBelowCloud()
// If Tick price near Cloud
      && IsPriceNearCloud_Sell()) {

      isSendSell = false;
      SendNotification("Sell: " + INPUT_SYMBOL);
      Print("Galaxy Sell!!!\r\n" + INPUT_SYMBOL);
   }

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
        ) {

         isSendTP = false;
         SendNotification("Take Profit: " + INPUT_SYMBOL);
         Print("Take Profit!!!\r\n" + INPUT_SYMBOL);
      }
   }
}
//+------------------------------------------------------------------+
