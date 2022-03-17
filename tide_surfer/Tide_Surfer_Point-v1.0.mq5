//+------------------------------------------------------------------------+
//| Tide Surfer on Point                                                   |
//| Copyright (C) <year>  <name of author>                                 |
//| This program is free software: you can redistribute it and/or modify   |
//| it under the terms of the GNU General Public License as published by   |
//| the Free Software Foundation, either version 3 of the License, or      |
//| (at your option) any later version.                                    |
//|                                                                        |
//| This program is distributed in the hope that it will be useful,        |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of         |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          |
//| GNU General Public License for more details.                           |
//|                                                                        |
//| You should have received a copy of the GNU General Public License      |
//| along with this program.  If not, see <https://www.gnu.org/licenses/>. |
//+------------------------------------------------------------------------+
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
input int input_fluc_point = 1000; // Fluctuation Points

// Check Timer
input int TIMER = 1800; // Checker Interval (Second)

// Variables
bool isSendNotification = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
// Welcome
    string content = "";
    StringAdd(content, "Tide Surfer on Point v" + VERSION);
    StringAdd(content, "\r\n");
    StringAdd(content, "Timeframe: ");
    StringAdd(content, EnumToString(input_timeframe1));
    StringAdd(content, ", ");
    StringAdd(content, EnumToString(input_timeframe2));
    StringAdd(content, ", ");
    StringAdd(content, EnumToString(input_timeframe3));
    SendNotification(content);

// Create timer
    EventSetTimer(TIMER); // Second to Minute

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
    if (isSendNotification) {
        MqlTick Latest_Price; // Structure to get the latest prices
        SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
        
        double openPrice = iOpen(NULL, timeframe, 0);
        double fluctuation = 0;
        // Convert Point to Price
        double input_fluc_price = input_fluc_point * Point();

        if (Latest_Price.ask > openPrice) {
            // If Bull Bar
            fluctuation = Latest_Price.ask - openPrice;

        } else if (openPrice > Latest_Price.bid) {
            // If Bear Bar
            fluctuation = openPrice - Latest_Price.bid;
        }

        // If Fluctuation price higher than expected
        if (fluctuation >= input_fluc_price) {
            SendNoti(timeframe);
            isSendNotification = false;
        }
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    isSendNotification = true;
}
//+------------------------------------------------------------------+