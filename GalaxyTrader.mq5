//+------------------------------------------------------------------+
//|                                                 GalaxyTrader.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                                                                  |
//+------------------------------------------------------------------+
// Include
#include "Common.mq5"
#include "Ichimoku.mq5"

// Parameters
const ENUM_TIMEFRAMES INPUT_TIMEFRAME = PERIOD_M30;
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
// Is send Take Profit notification
bool isSendTP = false;

// Default timer = 10mins = 600sec
const int default_timer = 600;

// M30 timer
int m30Timer = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SendNotification("Welcome to the Galaxy !!!\r\nSymbol: " + INPUT_SYMBOL);

//--- create timer
   EventSetTimer(default_timer);

// Check if valid symbol
   if(!isValidSymbol()) {
      return(0);
   }

// Initialize Ichimoku
   Ichimoku_handle = iIchimoku(INPUT_SYMBOL, INPUT_TIMEFRAME, 9, 26, 52);

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

   if (0 == 0
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
      SendNotification("Galaxy Buy!!!\r\n" + INPUT_SYMBOL);
      Print("Galaxy Buy!!!\r\n" + INPUT_SYMBOL);
   }

   if (isSendTP && IsBuying()) {
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

      // If Price touch Cloud
      if (Latest_Price.ask <= CurrentSenkouA()
          // If Cloud become Red cloud
          || CurrentSenkouA(default_amount - 1) < CurrentSenkouB(default_amount - 1)
          // If prev 3 closed price is going down
          || IsThreeFall()) {

         isSendTP = false;
         SendNotification("Take Profit!!!\r\n" + INPUT_SYMBOL);
         Print("Take Profit!!!\r\n" + INPUT_SYMBOL);
      }
   }
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
}
//+------------------------------------------------------------------+
