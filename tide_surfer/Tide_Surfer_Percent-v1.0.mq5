//+------------------------------------------------------------------+
//|                                           Tide Surfer on Percent |
//|                                   Copyright 2022, Pham Ngoc Vinh |
//|                    https://github.com/phamngocvinh/galaxy-trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Pham Ngoc Vinh"
#property link "https://github.com/phamngocvinh/galaxy-trader"
#define VERSION "1.0"
#property version VERSION

// Input parameters
// Chart Timeframe
input ENUM_TIMEFRAMES input_timeframe1 = PERIOD_M15; // Timeframe 1
input ENUM_TIMEFRAMES input_timeframe2 = PERIOD_M30; // Timeframe 2
input ENUM_TIMEFRAMES input_timeframe3 = PERIOD_H1; // Timeframe 3

// Fluctuation Points
input double input_fluc_percent = 0.5; // Fluctuation Percent

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
// Welcome
    string content = "";
    StringAdd(content, "Tide Surfer on Percent v" + VERSION);
    StringAdd(content, "\r\n");
    StringAdd(content, "Timeframe: ");
    StringAdd(content, EnumToString(input_timeframe1));
    StringAdd(content, ", ");
    StringAdd(content, EnumToString(input_timeframe2));
    StringAdd(content, ", ");
    StringAdd(content, EnumToString(input_timeframe3));
    SendNotification(content);

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    CheckForHighTide(input_timeframe1);
    CheckForHighTide(input_timeframe2);
    CheckForHighTide(input_timeframe3);
}

//+------------------------------------------------------------------+
//| Check for High Tide Bar                                          |
//+------------------------------------------------------------------+
void CheckForHighTide(ENUM_TIMEFRAMES timeframe)
{
    double openPrice = iOpen(NULL, timeframe, 0);
    double highPrice = iHigh(NULL, timeframe, 0);
    double lowPrice = iLow(NULL, timeframe, 0);
    double fluctuation = 0;

    if (highPrice > openPrice) {
        // If Bull Bar
        fluctuation = (highPrice - openPrice) / openPrice * 100;

    } else if (openPrice > lowPrice) {
        // If Bear Bar
        fluctuation = (openPrice - lowPrice) / lowPrice * 100;
    }

    // If Fluctuation price higher than expected
    if (fluctuation >= input_fluc_percent) {
        SendNoti(timeframe);
    }
}
//+------------------------------------------------------------------+
//| Send Notification                                                |
//+------------------------------------------------------------------+
void SendNoti(ENUM_TIMEFRAMES timeframe)
{
    string content = "Fluctuation happened on ";
    StringAdd(content, EnumToString(timeframe));
    StringAdd(content, " Timeframe");
    printf(content);
    SendNotification(content);
}
//+------------------------------------------------------------------+
