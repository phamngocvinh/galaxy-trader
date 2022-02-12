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
input ENUM_TIMEFRAMES TF1 = PERIOD_M30; // Timeframe 1
input ENUM_TIMEFRAMES TF2 = PERIOD_H1; // Timeframe 2
input ENUM_TIMEFRAMES TF3 = PERIOD_H4; // Timeframe 3

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
int Ichimoku_Handle_1;
int Ichimoku_Handle_2;
int Ichimoku_Handle_3;

bool isSendNotification = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
// Welcome
    string content = "";
    StringAdd(content, "Cloud Catcher Multi v" + VERSION);
    StringAdd(content, "\r\n");
    StringAdd(content, "Timeframe: " + TF1 + ", " + TF2 + ", " + TF3);
    StringAdd(content, "\r\n");

// Send Notification
    SendNotification(content);

// Create timer
    EventSetTimer(TIMER); // Second to Minute

// Initialize Ichimoku
    Ichimoku_Handle_1 = iIchimoku(CHART_SYMBOL, TF1, 9, 26, 52);
    Ichimoku_Handle_2 = iIchimoku(CHART_SYMBOL, TF2, 9, 26, 52);
    Ichimoku_Handle_3 = iIchimoku(CHART_SYMBOL, TF3, 9, 26, 52);

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

        CheckCloud(Ichimoku_Handle_1, Latest_Price.ask, TF1);
        CheckCloud(Ichimoku_Handle_2, Latest_Price.ask, TF2);
        CheckCloud(Ichimoku_Handle_3, Latest_Price.ask, TF3);
    }
}
//+------------------------------------------------------------------+
//| Check Cloud for Price touch                                                 |
//+------------------------------------------------------------------+
void CheckCloud(int ichimoku_Handle, double price, ENUM_TIMEFRAMES timeframe)
{
// Get ichimoku values
    FillArraysFromBuffers(Tenkan_Sen_Buffer,
                          Kijun_Sen_Buffer,
                          Senkou_Span_A_Buffer,
                          Senkou_Span_B_Buffer,
                          Chikou_Span_Buffer,
                          ichimoku_Handle);

    string strTimeFrame = EnumToString(timeframe);
    StringReplace(strTimeFrame, "PERIOD_", "");

    double margin_price = Point() * MARGIN;

    if (price <= CurrentSenkouA() + margin_price
            && price >= CurrentSenkouA() - margin_price) {

        printf("Price touch cloud A on " + strTimeFrame);
        SendNotification("Price touch cloud A on " + strTimeFrame);
        isSendNotification = false;

    }
    if (price <= CurrentSenkouB() + margin_price
            && price >= CurrentSenkouB() - margin_price) {

        printf("Price touch cloud B on " + strTimeFrame);
        SendNotification("Price touch cloud B on " + strTimeFrame);
        isSendNotification = false;

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
