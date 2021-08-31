//+------------------------------------------------------------------+
//|                                                 GalaxyTrader.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                                                                  |
//+------------------------------------------------------------------+
// Include
#include "Common.mq5"
#include "Ichimoku.mq5"

// Parameters
input double INPUT_LOT = 0.01;
input ENUM_TIMEFRAMES INPUT_TIMEFRAME = PERIOD_M30;
input string INPUT_SYMBOL = "USDJPY";

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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("--- Welcome to the Galaxy ---");

//--- create timer
   EventSetTimer(60);

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

   if (IsChikouAbovePrice()
       && CurrentTenkan() > CurrentKijun()
       && IsPriceClosedAboveCloud()) {
      Print("Buy");
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
