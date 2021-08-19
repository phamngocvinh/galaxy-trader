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
      FindGalaxy();
   }

   for (int idx = 0; idx < PositionsTotal(); idx++) {
      ClosePosition(idx);
   }
}

//+------------------------------------------------------------------+
//| Close position                                                   |
//+------------------------------------------------------------------+
void ClosePosition(int idx) {
   PositionGetSymbol(idx);
   double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
   double price_current = PositionGetDouble(POSITION_PRICE_CURRENT);

   if (0 == 0
         && isDownFall()
         && price_current - price_open > 1.07
      ) {
      trade.PositionClose(PositionGetInteger(POSITION_TICKET));
   }
}

//+------------------------------------------------------------------+
//| IsOnTop                                                          |
//+------------------------------------------------------------------+
bool isOnTop() {
// Get previous close price
   double prev_close[26];
   CopyClose(_Symbol, _Period, 0, 26, prev_close);
   
   
}

//+------------------------------------------------------------------+
//| Check if Downtrend occur                                         |
//+------------------------------------------------------------------+
bool isDownFall() {
// Get previous close price
   double prev_close[20];
   CopyClose(_Symbol, _Period, 0, 20, prev_close);
// Get previous open price
   double prev_open[20];
   CopyOpen(_Symbol, _Period, 0, 20, prev_open);

   if (0 == 0
// If price is going down
         && prev_open[0] > prev_close[0]
         && prev_open[1] > prev_close[1]
         && prev_open[2] > prev_close[2]
         && prev_open[3] > prev_close[3]
// If current price lower than previous price
         && prev_close[0] > prev_close[1]
         && prev_close[1] > prev_close[2]
         && prev_close[2] > prev_close[3]) {

      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Find Uptrend                                                     |
//+------------------------------------------------------------------+
void FindGalaxy() {
// Get previous 26 close price
   double prev_26_close[27];
   CopyClose(_Symbol, _Period, 0, 27, prev_26_close);
// Get ichimoku
   FillArraysFromBuffers(Tenkan_sen_Buffer, Kijun_sen_Buffer, Senkou_Span_A_Buffer, Senkou_Span_B_Buffer, Chinkou_Span_Buffer,
                         kijun_sen, Ichimoku_handle, values_to_copy);

   if(0 == 0
         && Chinkou_Span_Buffer[0] >= prev_26_close[26] // Chinkou-sen above Price
         && Tenkan_sen_Buffer[26] >= Kijun_sen_Buffer[26] // Tenkan-sen above Kijun-sen
         && prev_26_close[26] > prev_26_close[25]
         && prev_26_close[25] > prev_26_close[24]
         && prev_26_close[24] > prev_26_close[23]
// If Uptrend Cloud
         && ((Senkou_Span_A_Buffer[0] > Senkou_Span_B_Buffer[0]
              && Tenkan_sen_Buffer[26] > Senkou_Span_A_Buffer[0]
              && Tenkan_sen_Buffer[26] < Senkou_Span_A_Buffer[0] + 2.0)
             ||
// If Downtrend Cloud
             (Senkou_Span_A_Buffer[0] < Senkou_Span_B_Buffer[0]
              && Tenkan_sen_Buffer[26] > Senkou_Span_B_Buffer[0]
              && Tenkan_sen_Buffer[26] < Senkou_Span_B_Buffer[0] + 2.0))
     ) {
      // Send notification
      string message = "Found Galaxy !!!";
      SendNotification(message);
      Print(message);

      // Buy
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
      trade.Buy(0.02, NULL, 0.0, Latest_Price.ask - 5.0, Latest_Price.ask + 0.57, "Galaxy Buy");
   }
}

//+------------------------------------------------------------------+
//| Filling indicator buffers from the iIchimoku indicator           |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double & tenkan_sen_buffer[],    // indicator buffer of the Tenkan-sen line
                           double & kijun_sen_buffer[],     // indicator buffer of the Kijun_sen line
                           double & senkou_span_A_buffer[], // indicator buffer of the Senkou Span A line
                           double & senkou_span_B_buffer[], // indicator buffer of the Senkou Span B line
                           double & chinkou_span_buffer[],  // indicator buffer of the Chinkou Span line
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

//+------------------------------------------------------------------+
