//+------------------------------------------------------------------------+
//| Trailing Star on Point                                                 |
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

#include <Trade\Trade.mqh>

// Input parameters
input int entry_point; // Entry Point
input int trailing_point; // Trailing Point

// CTrade class
CTrade cTrade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
// Welcome
    string content = "";
    StringAdd(content, "Trailing Star v" + VERSION);
    StringAdd(content, "\r\n");
    StringAdd(content, "Entry point: ");
    StringAdd(content, IntegerToString(entry_point));
    StringAdd(content, " points");
    StringAdd(content, "\r\n");
    StringAdd(content, "Trailing point: ");
    StringAdd(content, IntegerToString(trailing_point));
    StringAdd(content, " points");
    SendNotification(content);

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    MqlTick latest_price; // Structure to get the latest prices
    SymbolInfoTick(Symbol(), latest_price); // Assign current prices to structure

// Loop through all position
    for (int idx = 0; idx < PositionsTotal(); idx++) {

        // Select position
        PositionGetSymbol(idx);

        double point = Point();
        double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);

        // If it's a BUY position
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            double profit_price = latest_price.bid - entry_price;

            if (profit_price > entry_point * point) {
                if (PositionGetDouble(POSITION_SL) != 0.0) {
                    // If Bid price higher than Trailing Point
                    if (latest_price.bid > PositionGetDouble(POSITION_SL) + (trailing_point * point)) {
                        double trailing_stop_loss = latest_price.bid - (trailing_point * point);
                        cTrade.PositionModify(PositionGetInteger(POSITION_TICKET), trailing_stop_loss, PositionGetDouble(POSITION_TP));
                    }
                } else {
                    double trailing_stop_loss = latest_price.bid - (trailing_point * point);
                    cTrade.PositionModify(PositionGetInteger(POSITION_TICKET), trailing_stop_loss, PositionGetDouble(POSITION_TP));
                }
            }
        }
        // If it's a SELL position
        else {
            double profit_price = entry_price - latest_price.ask;

            if (profit_price > entry_point * point) {
                if (PositionGetDouble(POSITION_SL) != 0.0) {
                    // If Ask price lower than Trailing Point
                    if (latest_price.ask < PositionGetDouble(POSITION_SL) - (trailing_point * point)) {
                        double trailing_stop_loss = latest_price.ask + (trailing_point * point);
                        cTrade.PositionModify(PositionGetInteger(POSITION_TICKET), trailing_stop_loss, PositionGetDouble(POSITION_TP));
                    }
                } else {
                    double trailing_stop_loss = latest_price.ask + (trailing_point * point);
                    cTrade.PositionModify(PositionGetInteger(POSITION_TICKET), trailing_stop_loss, PositionGetDouble(POSITION_TP));
                }
            }
        }
    }
}
//+------------------------------------------------------------------+
