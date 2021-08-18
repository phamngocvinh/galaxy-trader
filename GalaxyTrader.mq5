//+------------------------------------------------------------------+
//|                                                 GalaxyTrader.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Pham Ngoc Vinh"
#property link      "https://www.mql5.com"
#property version   "1.00"

// Include
#include <Trade\Trade.mqh>

//--- indicator buffer
input int tenkan_sen = 9; // period of Tenkan-sen
input int kijun_sen = 26; // period of Kijun-sen
input int senkou_span_b = 52; // period of Senkou Span B
double Tenkan_sen_Buffer[];
double Kijun_sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chinkou_Span_Buffer[];
//---- handles for indicators
int Ichimoku_handle; // handle of the indicator iIchimoku
int values_to_copy = 27;
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
// Get ichimoku
   Ichimoku_handle = iIchimoku(NULL, 0, 9, 26, 52);
// create a timer with a 5 minutes period
   EventSetTimer(5);
   Print("Welcome to the Galaxy!");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
// Destroy the timer after completing the work
   EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
   Print("Finding...");
   if (PositionsTotal() < 1) {
      FindBlackHole();
      FindGalaxy();
   }
}

//+------------------------------------------------------------------+
//| Find Downtrend                                                                 |
//+------------------------------------------------------------------+
void FindBlackHole() {
// Get previous 26 close price
   double prev_26_close[26];
   CopyClose(_Symbol, _Period, 0, 26, prev_26_close);
// Get ichimoku
   FillArraysFromBuffers(Tenkan_sen_Buffer, Kijun_sen_Buffer, Senkou_Span_A_Buffer, Senkou_Span_B_Buffer, Chinkou_Span_Buffer,
                         kijun_sen, Ichimoku_handle, values_to_copy);
// Tenkan-sen above Cloud
// Tenkan-sen above Kijun-sen
// Chinkou-sen above Price
// Uptrend cloud
   if(Tenkan_sen_Buffer[8] < Senkou_Span_B_Buffer[8]
         && Tenkan_sen_Buffer[8] < Kijun_sen_Buffer[8]
         && Tenkan_sen_Buffer[8] <= Tenkan_sen_Buffer[5]
         && Tenkan_sen_Buffer[5] <= Tenkan_sen_Buffer[2]
         && Tenkan_sen_Buffer[0] <= Kijun_sen_Buffer[0]
         && Chinkou_Span_Buffer[8] <= prev_26_close[25]
         && Senkou_Span_A_Buffer[8] < Senkou_Span_B_Buffer[8]) {
      // Send notification
      string message = "Found Black Hole !!!";
      SendNotification(message);
      Print(message);

      // Buy
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
      //trade.Sell(0.02, NULL, 0.0, 0.0, Latest_Price.bid - 0.57, "Galaxy Sell");
   }
}

//+------------------------------------------------------------------+
//| Find Uptrend                                                                 |
//+------------------------------------------------------------------+
void FindGalaxy() {
// Get previous 26 close price
   double prev_26_close[27];
   CopyClose(_Symbol, _Period, 0, 27, prev_26_close);
// Get ichimoku
   FillArraysFromBuffers(Tenkan_sen_Buffer, Kijun_sen_Buffer, Senkou_Span_A_Buffer, Senkou_Span_B_Buffer, Chinkou_Span_Buffer,
                         kijun_sen, Ichimoku_handle, values_to_copy);

   if(Tenkan_sen_Buffer[26] > Senkou_Span_B_Buffer[0] // Tenkan-sen above Cloud
         && Tenkan_sen_Buffer[26] > Kijun_sen_Buffer[26] // Tenkan-sen above Kijun-sen
         && Tenkan_sen_Buffer[26] >= Tenkan_sen_Buffer[23]
         && Tenkan_sen_Buffer[23] >= Tenkan_sen_Buffer[20]
         && Tenkan_sen_Buffer[26] >= Kijun_sen_Buffer[26]
         && Chinkou_Span_Buffer[0] >= prev_26_close[0] // Chinkou-sen above Price
         && Senkou_Span_A_Buffer[0] > Senkou_Span_B_Buffer[0]) { // Uptrend cloud
      // Send notification
      string message = "Found Galaxy !!!";
      SendNotification(message);
      Print(message);

      // Buy
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
      trade.Buy(0.02, NULL, 0.0, 0.0, Latest_Price.ask + 0.57, "Galaxy Buy");
   }
}

//+------------------------------------------------------------------+
//| Filling indicator buffers from the iIchimoku indicator           |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double &tenkan_sen_buffer[],     // indicator buffer of the Tenkan-sen line
                           double &kijun_sen_buffer[],      // indicator buffer of the Kijun_sen line
                           double &senkou_span_A_buffer[],  // indicator buffer of the Senkou Span A line
                           double &senkou_span_B_buffer[],  // indicator buffer of the Senkou Span B line
                           double &chinkou_span_buffer[],   // indicator buffer of the Chinkou Span line
                           int senkou_span_shift,           // shift of the Senkou Span lines in the future direction
                           int ind_handle,                  // handle of the iIchimoku indicator
                           int amount                       // number of copied values
                          ) {
//--- reset error code
   ResetLastError();
//--- fill a part of the Tenkan_sen_Buffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle, 0, 0, amount, tenkan_sen_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("1.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Kijun_sen_Buffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle, 1, 0, amount, kijun_sen_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("2.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Chinkou_Span_Buffer array with values from the indicator buffer that has index 2
//--- if senkou_span_shift>0, the line is shifted in the future direction by senkou_span_shift bars
   if(CopyBuffer(ind_handle, 2, -senkou_span_shift, amount, senkou_span_A_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("3.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Senkou_Span_A_Buffer array with values from the indicator buffer that has index 3
//--- if senkou_span_shift>0, the line is shifted in the future direction by senkou_span_shift bars
   if(CopyBuffer(ind_handle, 3, -senkou_span_shift, amount, senkou_span_B_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("4.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Senkou_Span_B_Buffer array with values from the indicator buffer that has 0 index
//--- when copying Chinkou Span, we don't need to consider the shift, since the Chinkou Span data
//--- is already stored with a shift in iIchimoku
   if(CopyBuffer(ind_handle, 4, 0, amount, chinkou_span_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("5.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- everything is fine
   return(true);
}
//+------------------------------------------------------------------+
