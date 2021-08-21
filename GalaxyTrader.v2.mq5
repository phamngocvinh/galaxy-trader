//+------------------------------------------------------------------+
//|                                              GalaxyTrader.v2.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Pham Ngoc Vinh"
#property link      ""
#property version   "1.00"

// Include
#include <Trade\Trade.mqh>

CTrade trade;

double Tenkan_sen_Buffer[];
double Kijun_sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chikou_Span_Buffer[];
int Ichimoku_handle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//--- create timer
   EventSetTimer(60);


// Initialize Ichimoku
   Ichimoku_handle = iIchimoku(NULL, 0, 9, 26, 52);

   Print("--- Welcome to the Galaxy ---");
   Print("Created by Pham Ngoc Vinh!");
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
// Get ichimoku values
   FillArraysFromBuffers(Tenkan_sen_Buffer,
                         Kijun_sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         Ichimoku_handle);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---

}//+------------------------------------------------------------------+
//| Filling indicator buffers from the iIchimoku indicator           |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double & tenkan_sen_buffer[],    // indicator buffer of the Tenkan-sen line
                           double & kijun_sen_buffer[],     // indicator buffer of the Kijun_sen line
                           double & senkou_span_A_buffer[], // indicator buffer of the Senkou Span A line
                           double & senkou_span_B_buffer[], // indicator buffer of the Senkou Span B line
                           double & chinkou_span_buffer[],  // indicator buffer of the Chinkou Span line
                           int ind_handle                   // handle of the iIchimoku indicator
                          ) {
   // Shift of the Senkou Span lines in the future direction
   int senkou_span_shift = 26;
   // number of copied values
   int amount = 27;
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
