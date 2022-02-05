//+------------------------------------------------------------------+
//|                                                  DailyChange.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                    https://github.com/phamngocvinh/galaxy-trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Pham Ngoc Vinh"
#property link      "https://github.com/phamngocvinh/galaxy-trader"
#define VERSION "1.1"
#property version VERSION

//--- Input Parameters
input int      numOfDays = 3; // Number of past days changes
input int      hour = 7; // Notification Hour
input int      minute = 0; // Notification Minute

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
    // Get current time
    MqlDateTime currectTime;
    TimeCurrent(currectTime);

// Welcome
    string content = "";
    StringAdd(content, "Daily Change v" + VERSION);
    StringAdd(content, "\r\n");

    for(int i = 1; i <= numOfDays; i++) {
        // Get High Price
        double high = iHigh(NULL, PERIOD_D1, i);
        // Get Low Price
        double low = iLow(NULL, PERIOD_D1, i);
        // Get Open Price
        double open = iOpen(NULL, PERIOD_D1, i);
        // Get Close Price
        double close = iClose(NULL, PERIOD_D1, i);
        // Get Previous Close Price
        double prevClose = iClose(NULL, PERIOD_D1, i + 1);
        // Get Bar Time
        datetime date = iTime(NULL, PERIOD_D1, i);
        MqlDateTime dt;
        TimeToStruct(date, dt);

        double highChange = (high - open) / open * 100;
        double lowChange = (low - open) / open * 100;
        double closeChange = (close - open) / open * 100;
        double prevCloseChange = (close - prevClose) / close * 100;

        StringAdd(content, getDayOfWeek(dt.day_of_week));
        StringAdd(content, " - ");
        StringAdd(content, IntegerToString(dt.year));
        StringAdd(content, "/");
        StringAdd(content, IntegerToString(dt.mon));
        StringAdd(content, "/");
        StringAdd(content, IntegerToString(dt.day));
        StringAdd(content, "\r\n");

        StringAdd(content, "High:  ");
        StringAdd(content, DoubleToString(high, 2));
        StringAdd(content, "  ");
        StringAdd(content, DoubleToString(highChange, 2));
        StringAdd(content, "%\r\n");

        StringAdd(content, "Low:   ");
        StringAdd(content, DoubleToString(low, 2));
        StringAdd(content, "  ");
        StringAdd(content, DoubleToString(lowChange, 2));
        StringAdd(content, "%\r\n");

        StringAdd(content, "Close: ");
        StringAdd(content, DoubleToString(close, 2));
        StringAdd(content, "  ");
        StringAdd(content, DoubleToString(closeChange, 2));
        StringAdd(content, "%\r\n");

        StringAdd(content, "Prev: ");
        StringAdd(content, DoubleToString(prevClose, 2));
        StringAdd(content, "  ");
        StringAdd(content, DoubleToString(prevCloseChange, 2));
        StringAdd(content, "%\r\n");

        StringAdd(content, "\r\n");
    }

// Send Notification
    SendNotification(content);

//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Get day name                                                     |
//+------------------------------------------------------------------+
string getDayOfWeek(int day_of_week)
{
    if(day_of_week == 1) {
        return "Mon";
    } else if(day_of_week == 2) {
        return "Tue";
    } else if(day_of_week == 3) {
        return "Wed";
    } else if(day_of_week == 4) {
        return "Thu";
    } else if(day_of_week == 5) {
        return "Fri";
    }
    return "";
}
//+------------------------------------------------------------------+
