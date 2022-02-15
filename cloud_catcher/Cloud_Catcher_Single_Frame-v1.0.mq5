//+------------------------------------------------------------------+
//|                                       Cloud Catcher Single Frame |
//|                                   Copyright 2022, Pham Ngoc Vinh |
//|                    https://github.com/phamngocvinh/galaxy-trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Pham Ngoc Vinh"
#property link      "https://github.com/phamngocvinh/galaxy-trader"
#define VERSION "1.0"
#property version VERSION

// Include
#include "../common/Ichimoku.mq5"

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
input int TIMER = 1800; // Checker Interval (Second)

// Margin
input int MARGIN = 50; // PIP Margin

// Variables
// Ichimoku
double Tenkan_Sen_Buffer[];
double Kijun_Sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chikou_Span_Buffer[];

// Ichimoku Handles
int Ichimoku_Handle;

bool isSendNotification = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
// Welcome
    string content = "";
    StringAdd(content, "Cloud Catcher Single v" + VERSION);
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
    if (isSendNotification) {
        MqlTick Latest_Price; // Structure to get the latest prices
        SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

        // Get ichimoku values
        FillArraysFromBuffers(Tenkan_Sen_Buffer,
                              Kijun_Sen_Buffer,
                              Senkou_Span_A_Buffer,
                              Senkou_Span_B_Buffer,
                              Chikou_Span_Buffer,
                              Ichimoku_Handle);

        double margin_price = Point() * MARGIN;

        if (Latest_Price.bid <= CurrentSenkouA() + margin_price
                && Latest_Price.bid >= CurrentSenkouA() - margin_price) {

            printf("Price touch cloud A");
            SendNotification("Price touch cloud A");
            isSendNotification = false;

        }
        if (Latest_Price.bid <= CurrentSenkouB() + margin_price
                && Latest_Price.bid >= CurrentSenkouB() - margin_price) {

            printf("Price touch cloud B");
            SendNotification("Price touch cloud B");
            isSendNotification = false;

        }
    }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    isSendNotification = true;
}
//+------------------------------------------------------------------+
