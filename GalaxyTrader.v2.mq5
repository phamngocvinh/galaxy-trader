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

// Parameters
input double INPUT_LOT = 0.05;
input ENUM_TIMEFRAMES INPUT_TIMEFRAME = PERIOD_M30;
input string INPUT_SYMBOL = "USDJPY";

// number of copied values
const int amount = 30;
// number of copied values
const int default_amount = 27;

// CTrade
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

   Print("--- Welcome to the Galaxy ---");
   Print("Created by Pham Ngoc Vinh!");

// Check if valid symbol
   if(!SymbolSelect(INPUT_SYMBOL, true)) {
      Print("Invalid symbol!");
      ExpertRemove();
      return(0);
   }

// Initialize Ichimoku
   Ichimoku_handle = iIchimoku(INPUT_SYMBOL, INPUT_TIMEFRAME, 9, 26, 52);

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

   GalaxyBuy();
   TakeProfit();
   StopLoss();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---

}
//+------------------------------------------------------------------+
//| Adjust Stop Loss                                                 |
//+------------------------------------------------------------------+
void StopLoss() {
// Set stop loss according to cloud
   for(int idx = 0; idx < PositionsTotal(); idx++) {
      trade.PositionModify(PositionGetTicket(idx), FindStopLossBuy(), 0.0);
   }
}
//+------------------------------------------------------------------+
//| Find Stop Loss for Buy Position                                  |
//+------------------------------------------------------------------+
double FindStopLossBuy() {
   for(int i = amount - default_amount; i < ArraySize(Senkou_Span_A_Buffer); i++) {
      if (Senkou_Span_A_Buffer[i] > Senkou_Span_B_Buffer[i]) {
         return Senkou_Span_B_Buffer[i] - (Point() * 30);
      }
   }
   return 0;
}
//+------------------------------------------------------------------+
//| Take Profit                                                      |
//+------------------------------------------------------------------+
void TakeProfit() {

   for(int idx = 0; idx < PositionsTotal(); idx++) {
      PositionGetSymbol(idx);

      double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
      double price_current = PositionGetDouble(POSITION_PRICE_CURRENT);

      if(price_current > price_open + (200 * Point())
            && (IsTenkanCrossKijun()
                || IsChikouTouchPrice()
                || IsThreeFall())) {
         trade.PositionClose(PositionGetInteger(POSITION_TICKET));
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsThreeFall() {

// Get previous low price
   double prev_close[4];
   CopyClose(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 4, prev_close);

   if (prev_close[3] < prev_close[2]
         && prev_close[2] < prev_close[1]
         && prev_close[1] < prev_close[0]) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Buy Command                                                      |
//+------------------------------------------------------------------+
void GalaxyBuy() {
   if (PositionsTotal() < 1
         && IsChikouAbovePrice()
         && IsPriceAboveCloud()
         && CurrentTenkan() > CurrentKijun()
         && IsPriceNearCloud()) {
      // Buy
      trade.Buy(INPUT_LOT, INPUT_SYMBOL, 0.0, FindStopLossBuy(), 0.0, "Galaxy Buy");
   }
}
//+------------------------------------------------------------------+
//| IsPriceNearCloud                                                 |
//+------------------------------------------------------------------+
bool IsPriceNearCloud() {
   MqlTick Latest_Price; // Structure to get the latest prices
   SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

   if (IsGreenCloud()
         && Latest_Price.ask < CurrentSenkouA() + (50 * Point())) {
      return true;
   } else if (IsRedCloud()
              && Latest_Price.ask < CurrentSenkouB() + (50 * Point())) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Is Chikou Touch Price                                            |
//+------------------------------------------------------------------+
bool IsChikouTouchPrice() {
// Get previous high price
   double prev_open[27];
   CopyOpen(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 27, prev_open);
// Get previous low price
   double prev_close[27];
   CopyClose(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 27, prev_close);

   if(CurrentChikou() < prev_open[0]
         && CurrentChikou() > prev_close[0]) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Is Tenkan Cross Kijun                                            |
//+------------------------------------------------------------------+
bool IsTenkanCrossKijun() {
   if (CurrentTenkan() == CurrentKijun()) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| IsPriceAboveCloud                                                |
//+------------------------------------------------------------------+
bool IsPriceAboveCloud() {
// Get previous close price
   double prev_close[3];
   CopyClose(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 3, prev_close);

   MqlTick Latest_Price; // Structure to get the latest prices
   SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

   if(IsGreenCloud()
         && prev_close[2] > CurrentSenkouA()
         && prev_close[1] > CurrentSenkouA()
         && Latest_Price.ask > prev_close[1]) {
      Print("Price above Cloud");
      return true;
   }
   if(IsRedCloud()
         && prev_close[2] > CurrentSenkouB()
         && prev_close[1] > CurrentSenkouB()
         && Latest_Price.ask > prev_close[1]) {
      Print("Price above Cloud");
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Is Uptrend Cloud                                                 |
//+------------------------------------------------------------------+
bool IsGreenCloud() {
   if (CurrentSenkouA() > CurrentSenkouB()
         && CurrentSenkouA(-1) > CurrentSenkouB(-1)
         && CurrentSenkouA(-2) > CurrentSenkouB(-2)) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Is Downtrend Cloud                                                 |
//+------------------------------------------------------------------+
bool IsRedCloud() {
   if (CurrentSenkouA() < CurrentSenkouB()
         && CurrentSenkouA(-1) < CurrentSenkouB(-1)
         && CurrentSenkouA(-2) < CurrentSenkouB(-2)) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| IsChikouAbovePrice                                               |
//+------------------------------------------------------------------+
bool IsChikouAbovePrice() {
// Get previous open price
   double prev_open[29];
   CopyOpen(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 29, prev_open);

   if (CurrentChikou() > prev_open[1]) {
      Print("Chikou above Price");
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Get Current Chikou Value                                         |
//+------------------------------------------------------------------+
double CurrentChikou(int shift = 0) {
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - default_amount + shift;
   return Chikou_Span_Buffer[idx];
}
//+------------------------------------------------------------------+
//| Get Current Senkou Span A Value                                  |
//+------------------------------------------------------------------+
double CurrentSenkouA(int shift = 0) {
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - default_amount + shift;
   return Senkou_Span_A_Buffer[idx];
}
//+------------------------------------------------------------------+
//| Get Current Senkou Span B Value                                  |
//+------------------------------------------------------------------+
double CurrentSenkouB(int shift = 0) {
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - default_amount + shift;
   return Senkou_Span_B_Buffer[idx];
}
//+------------------------------------------------------------------+
//| Get Current Tenkan Value                                         |
//+------------------------------------------------------------------+
double CurrentTenkan(int shift = 0) {
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - 1 + shift;
   return Tenkan_sen_Buffer[idx];
}
//+------------------------------------------------------------------+
//| Get Current Tenkan Value                                         |
//+------------------------------------------------------------------+
double CurrentKijun(int shift = 0) {
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - 1 + shift;
   return Kijun_sen_Buffer[idx];
}
//+------------------------------------------------------------------+
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
