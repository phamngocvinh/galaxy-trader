//+------------------------------------------------------------------+
//|                                                 CloudCatcher.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                    https://github.com/phamngocvinh/galaxy-trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Pham Ngoc Vinh"
#property link      "https://github.com/phamngocvinh/galaxy-trader"
#define VERSION "1.0"
#property version VERSION

// Include
#include "ichimoku.mq5"

//--- Constants
// Number of copied values
const int AMOUNT = 30;
// Default number of copied values
const int DEFAULT_AMOUNT = 27;

// Chart Symbol
const string CHART_SYMBOL = ChartSymbol();

// Parameters
// Chart Timeframe
const ENUM_TIMEFRAMES CHART_TF = Period();

// Check Timer
input int TIMER = 300; // Checker Interval (Second)

// Variables
// Ichimoku
double Tenkan_Sen_Buffer[];
double Kijun_Sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chikou_Span_Buffer[];

// Ichimoku Handles
int Ichimoku_Handle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
// Welcome
    string content = "";
    StringAdd(content, "Cloud Catcher v" + VERSION);
    StringAdd(content, "\r\n");
    StringAdd(content, "Timeframe: " + CHART_TF);
    StringAdd(content, "\r\n");

// Send Notification
    SendNotification(content);

// Create timer
    EventSetTimer(TIMER); // Second to Minute

// Initialize Ichimoku
    Ichimoku_Handle = iIchimoku(CHART_SYMBOL, CHART_TF, 9, 26, 52);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    MqlTick Latest_Price; // Structure to get the latest prices
    SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
}
//+------------------------------------------------------------------+
