//+------------------------------------------------------------------+
//|                                                Trend Catcher.mq5 |
//|                                                    Version 0.4.4 |
//|                                   Copyright 2022, Pham Ngoc Vinh |
//+------------------------------------------------------------------+
// Include
#include "Common.mq5"
#include "Common_Buy.mq5"
#include "Common_Sell.mq5"
#include "../common/Ichimoku.mq5"

// Constants
// Symbol
const string INPUT_SYMBOL = ChartSymbol();
// Version
const string VERSION = "v0.4.4";
// Number of copied values
const int AMOUNT = 30;
// Default number of copied values
const int DEFAULT_AMOUNT = 27;

// Parameters
// Entry Timeframe
input ENUM_TIMEFRAMES ENTRY_TIMEFRAME_1 = PERIOD_M15;// Entry TimeFrame 1
input ENUM_TIMEFRAMES ENTRY_TIMEFRAME_2 = PERIOD_M30;// Entry TimeFrame 2
input ENUM_TIMEFRAMES ENTRY_TIMEFRAME_3 = PERIOD_H1;// Entry TimeFrame 3

// TP Timeframe
input ENUM_TIMEFRAMES TP_TIMEFRAME_1 = PERIOD_M15;// Take Profit TimeFrame 1
input ENUM_TIMEFRAMES TP_TIMEFRAME_2 = PERIOD_M30;// Take Profit TimeFrame 2
input ENUM_TIMEFRAMES TP_TIMEFRAME_3 = PERIOD_H1;// Take Profit TimeFrame 3

// Point Gap
input int POINT_GAP = 100; // Range between cloud and price

// Check Timer
input int TIMER = 1800; // Checker Interval (Second)

// Max Trade Num
input int MAX_TRADE = 3;// Total Number of Trade

// Variables
// Ichimoku
double Tenkan_Sen_Buffer[];
double Kijun_Sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chikou_Span_Buffer[];

// Ichimoku Handles
int Ichimoku_Handle_ET_1;
int Ichimoku_Handle_ET_2;
int Ichimoku_Handle_ET_3;
int Ichimoku_Handle_TP_1;
int Ichimoku_Handle_TP_2;
int Ichimoku_Handle_TP_3;

// Timer Counter
int Timer_Entry_1 = 0;
int Timer_Entry_2 = 0;
int Timer_Entry_3 = 0;

int Timer_TP_1 = 0;
int Timer_TP_2 = 0;
int Timer_TP_3 = 0;

// Send Notification Flag
bool isSendEntry_1 = false;
bool isSendEntry_2 = false;
bool isSendEntry_3 = false;
bool isSendTP_1 = false;
bool isSendTP_2 = false;
bool isSendTP_3 = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SendNotification("Trend Catcher " + VERSION + "\r\nSymbol: " + INPUT_SYMBOL);

//--- create timer
   EventSetTimer(TIMER); // Second to Minute

// Check if valid symbol
   if(!isValidSymbol()) {
      return(0);
   }

// Initialize Ichimoku
   Ichimoku_Handle_ET_1 = iIchimoku(INPUT_SYMBOL, ENTRY_TIMEFRAME_1, 9, 26, 52);
   Ichimoku_Handle_ET_2 = iIchimoku(INPUT_SYMBOL, ENTRY_TIMEFRAME_2, 9, 26, 52);
   Ichimoku_Handle_ET_3 = iIchimoku(INPUT_SYMBOL, ENTRY_TIMEFRAME_3, 9, 26, 52);
   Ichimoku_Handle_TP_1 = iIchimoku(INPUT_SYMBOL, TP_TIMEFRAME_1, 9, 26, 52);
   Ichimoku_Handle_TP_2 = iIchimoku(INPUT_SYMBOL, TP_TIMEFRAME_2, 9, 26, 52);
   Ichimoku_Handle_TP_3 = iIchimoku(INPUT_SYMBOL, TP_TIMEFRAME_3, 9, 26, 52);

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
// Process Buy Order
   ProcessBuy(isSendEntry_1, isSendTP_1, ENTRY_TIMEFRAME_1, Ichimoku_Handle_ET_1, Ichimoku_Handle_TP_1);
   ProcessBuy(isSendEntry_2, isSendTP_2, ENTRY_TIMEFRAME_2, Ichimoku_Handle_ET_2, Ichimoku_Handle_TP_2);
   ProcessBuy(isSendEntry_3, isSendTP_3, ENTRY_TIMEFRAME_3, Ichimoku_Handle_ET_3, Ichimoku_Handle_TP_3);

// Processing Sell command
   ProcessSell(isSendEntry_1, isSendTP_1, ENTRY_TIMEFRAME_1, Ichimoku_Handle_ET_1, Ichimoku_Handle_TP_1);
   ProcessSell(isSendEntry_2, isSendTP_2, ENTRY_TIMEFRAME_2, Ichimoku_Handle_ET_2, Ichimoku_Handle_TP_2);
   ProcessSell(isSendEntry_3, isSendTP_3, ENTRY_TIMEFRAME_3, Ichimoku_Handle_ET_3, Ichimoku_Handle_TP_3);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
// Count timer
   Timer_Entry_1 += TIMER;
   Timer_Entry_2 += TIMER;
   Timer_Entry_3 += TIMER;
   Timer_TP_1 += TIMER;
   Timer_TP_2 += TIMER;
   Timer_TP_3 += TIMER;

   if (Timer_Entry_1 >= getTimeframeSecond(ENTRY_TIMEFRAME_1)) {
      isSendEntry_1 = true;
      Timer_Entry_1 = 0;
   }

   if (Timer_Entry_2 >= getTimeframeSecond(ENTRY_TIMEFRAME_2)) {
      isSendEntry_2 = true;
      Timer_Entry_2 = 0;
   }

   if (Timer_Entry_3 >= getTimeframeSecond(ENTRY_TIMEFRAME_3)) {
      isSendEntry_3 = true;
      Timer_Entry_3 = 0;
   }

   if (Timer_TP_1 >= getTimeframeSecond(TP_TIMEFRAME_1)) {
      isSendTP_1 = true;
      Timer_TP_1 = 0;
   }

   if (Timer_TP_2 >= getTimeframeSecond(TP_TIMEFRAME_2)) {
      isSendTP_2 = true;
      Timer_TP_2 = 0;
   }

   if (Timer_TP_3 >= getTimeframeSecond(TP_TIMEFRAME_3)) {
      isSendTP_3 = true;
      Timer_TP_3 = 0;
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy Process                                                      |
//+------------------------------------------------------------------+
void ProcessBuy(bool &isSendEntry, bool &isSendTP, ENUM_TIMEFRAMES timeframe, int handle_entry, int handle_tp)
{
   string strTimeFrame = EnumToString(timeframe);
   StringReplace(strTimeFrame, "PERIOD_", "");

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_Sen_Buffer,
                         Kijun_Sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         handle_entry);

   if(0 == 0
// Is Send Entry Notification
      && isSendEntry
// If currently not trading
      && !IsSelling() && !IsBuying()
// If Chiukou-sen above Price
      && IsChikouAbovePrice(timeframe)
// If Tenkan > Kijun
      && CurrentTenkan() > CurrentKijun()
// If Price Closed Above Cloud
      && IsPriceClosedAboveCloud(timeframe)
// If Tick price near Cloud
      && IsPriceNearCloud()
// If Maximun Trader Num not reach
      && PositionsTotal() <= MAX_TRADE) {

      sendEntry(isSendEntry, "Buy", strTimeFrame);
   }

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_Sen_Buffer,
                         Kijun_Sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         handle_tp);

   if(isSendTP && IsBuying() && IsProfit()) {
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

      // If Price touch Cloud
      if (Latest_Price.ask <= CurrentSenkouA()
          && CurrentSenkouA() >= CurrentSenkouB()) {
         sendTP(isSendTP, strTimeFrame, "Price touch Cloud");
      }
      // If previous 3 closed price is going down
      else if (IsThreeFall(timeframe)) {
         sendTP(isSendTP, strTimeFrame, "Three Fall");
      }
      // If Tenkan Cross Kijun From Above
      else if (IsTenkanCrossKijunFromAbove()) {
         sendTP(isSendTP, strTimeFrame, "Tenkan cross Kijun");
      }
   }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Sell Process                                                     |
//+------------------------------------------------------------------+
void ProcessSell(bool &isSendEntry, bool &isSendTP, ENUM_TIMEFRAMES timeframe, int handle_entry, int handle_tp)
{
   string strTimeFrame = EnumToString(timeframe);
   StringReplace(strTimeFrame, "PERIOD_", "");

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_Sen_Buffer,
                         Kijun_Sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         handle_entry);

   if(0 == 0
// Is Send Sell Notification
      && isSendEntry
// If currently not trading
      && !IsSelling() && !IsBuying()
// If Chiukou-sen below Price
      && IsChikouBelowPrice(timeframe)
// If Tenkan < Kijun
      && CurrentTenkan() < CurrentKijun()
// If Price Closed Below Cloud
      && IsPriceClosedBelowCloud(timeframe)
// If Tick price near Cloud
      && IsPriceNearCloud_Sell()
// If Maximun Trader Num not reach
      && PositionsTotal() <= MAX_TRADE) {

      sendEntry(isSendEntry, "Sell", strTimeFrame);
   }

// Get ichimoku values
   FillArraysFromBuffers(Tenkan_Sen_Buffer,
                         Kijun_Sen_Buffer,
                         Senkou_Span_A_Buffer,
                         Senkou_Span_B_Buffer,
                         Chikou_Span_Buffer,
                         handle_tp);

   if(isSendTP && IsSelling() && IsProfit_Sell()) {
      MqlTick Latest_Price; // Structure to get the latest prices
      SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

      // If Price touch Cloud
      if(Latest_Price.ask >= CurrentSenkouA()
         && CurrentSenkouB() >= CurrentSenkouA()) {
         sendTP(isSendTP, strTimeFrame, "Price touch Cloud");
      }
      // If prev 3 closed price is going up
      else if (IsThreeRise(timeframe)) {
         sendTP(isSendTP, strTimeFrame, "Three Rise");
      }
      // If Tenkan Cross Kijun From Above
      else if (IsTenkanCrossKijunFromBelow()) {
         sendTP(isSendTP, strTimeFrame, "Tenkan cross Kijun");
      }
   }
}
//+------------------------------------------------------------------+
