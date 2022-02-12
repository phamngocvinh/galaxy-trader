//+------------------------------------------------------------------+
//|                                                 TrailingStar.mq5 |
//|                                   Copyright 2021, Pham Ngoc Vinh |
//|                    https://github.com/phamngocvinh/galaxy-trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Pham Ngoc Vinh"
#property link "https://github.com/phamngocvinh/galaxy-trader"
#define VERSION "1.0"
#property version VERSION

#include <Trade\Trade.mqh>

// Input parameters
input double entry_price; // Entry Price
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
    StringAdd(content, "Entry price: ");
    StringAdd(content, entry_price);
    StringAdd(content, " points");
    StringAdd(content, "\r\n");
    StringAdd(content, "Trailing point: ");
    StringAdd(content, trailing_point);
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

            if (profit_price > entry_price) {
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

            if (profit_price > entry_price) {
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
