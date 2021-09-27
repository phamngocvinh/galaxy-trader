//+------------------------------------------------------------------+
//|                                                 GalaxyTrader.mq5 |
//|                                                      Version 0.3 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//+------------------------------------------------------------------+
// Include
#include "Common.mq5"
#include "Common_Buy.mq5"
#include "Common_Sell.mq5"
#include "Ichimoku.mq5"
#include <Trade\Trade.mqh>

// Constants
// Symbol
const string INPUT_SYMBOL = ChartSymbol();
// Version
const string VERSION = "v0.3";
// Number of copied values
const int AMOUNT = 30;
// Default number of copied values
const int DEFAULT_AMOUNT = 27;

// Check timer
const int TIMER = 60; // Default 1 minute

// Parameters
// Entry Timeframe
input ENUM_TIMEFRAMES ENTRY_TIMEFRAME_1 = PERIOD_M30;// Entry TimeFrame 1
input ENUM_TIMEFRAMES ENTRY_TIMEFRAME_2 = PERIOD_H1;// Entry TimeFrame 2
input ENUM_TIMEFRAMES ENTRY_TIMEFRAME_3 = PERIOD_H4;// Entry TimeFrame 3

// TP Timeframe
input ENUM_TIMEFRAMES TP_TIMEFRAME_1 = PERIOD_M15;// Take Profit TimeFrame 1
input ENUM_TIMEFRAMES TP_TIMEFRAME_2 = PERIOD_M30;// Take Profit TimeFrame 2
input ENUM_TIMEFRAMES TP_TIMEFRAME_3 = PERIOD_H1;// Take Profit TimeFrame 3

// Point Gap
input int POINT_GAP = 200; // Range between cloud and price

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

// Is Debug Mode
const bool isDebug = false;
CTrade cTrade;
CPositionInfo cPosition;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SendNotification("Galaxy Trader " + VERSION + "\r\nSymbol: " + INPUT_SYMBOL);

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

   if (Timer_Entry_1 == getTimeframeSecond(ENTRY_TIMEFRAME_1)) {
      isSendEntry_1 = true;
      Timer_Entry_1 = 0;
   }

   if (Timer_Entry_2 == getTimeframeSecond(ENTRY_TIMEFRAME_2)) {
      isSendEntry_2 = true;
      Timer_Entry_2 = 0;
   }

   if (Timer_Entry_3 == getTimeframeSecond(ENTRY_TIMEFRAME_3)) {
      isSendEntry_3 = true;
      Timer_Entry_3 = 0;
   }

   if (Timer_TP_1 == getTimeframeSecond(TP_TIMEFRAME_1)) {
      isSendTP_1 = true;
      Timer_TP_1 = 0;
   }

   if (Timer_TP_2 == getTimeframeSecond(TP_TIMEFRAME_2)) {
      isSendTP_2 = true;
      Timer_TP_2 = 0;
   }

   if (Timer_TP_3 == getTimeframeSecond(TP_TIMEFRAME_3)) {
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
      && IsPriceNearCloud()) {

      isSendEntry = false;
      SendNotification(strTimeFrame + " - Buy: " + INPUT_SYMBOL);

      if (isDebug) {
         cTrade.Buy(0.02, NULL, 0.0, 0.0, 0.0);
         Print(strTimeFrame + " - Buy: " + INPUT_SYMBOL);
      }
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
      if(Latest_Price.ask <= CurrentSenkouA()
         // If Cloud become Red cloud
         || CurrentSenkouA(DEFAULT_AMOUNT - 1) < CurrentSenkouB(DEFAULT_AMOUNT - 1)
         // If prev 3 closed price is going down
         || IsThreeFall(timeframe)
         // If Tenkan Cross Kijun From Above
         || IsTenkanCrossKijunFromAbove()
        ) {

         isSendTP = false;
         SendNotification(strTimeFrame + " - Take Profit: " + INPUT_SYMBOL);

         if (isDebug) {
            cPosition.SelectByIndex(0);
            cTrade.PositionClose(cPosition.Ticket());
            Print(strTimeFrame + " - Take Profit: " + INPUT_SYMBOL);
         }
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
      && IsPriceNearCloud_Sell()) {

      isSendEntry = false;
      SendNotification(strTimeFrame + " - Sell: " + INPUT_SYMBOL);

      if (isDebug) {
         cTrade.Sell(0.02, NULL, 0.0, 0.0, 0.0);
         Print(strTimeFrame + " - Sell: " + INPUT_SYMBOL);
      }
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
      if(Latest_Price.ask >= CurrentSenkouB()
         // If Cloud become Green cloud
         || CurrentSenkouA(DEFAULT_AMOUNT - 1) > CurrentSenkouB(DEFAULT_AMOUNT - 1)
         // If prev 3 closed price is going up
         || IsThreeRise(timeframe)
         // If Tenkan Cross Kijun From Above
         || IsTenkanCrossKijunFromBelow()
        ) {

         isSendTP = false;
         SendNotification(strTimeFrame + " - Take Profit: " + INPUT_SYMBOL);

         if (isDebug) {
            cPosition.SelectByIndex(0);
            cTrade.PositionClose(cPosition.Ticket());
            Print(strTimeFrame + " - Take Profit: " + INPUT_SYMBOL);
         }
      }
   }
}
//+------------------------------------------------------------------+
