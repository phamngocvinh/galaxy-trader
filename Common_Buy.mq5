//+------------------------------------------------------------------+
//| Buy Functions                                                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check if current price is near cloud                             |
//+------------------------------------------------------------------+
bool IsPriceNearCloud()
{
   MqlTick Latest_Price; // Structure to get the latest prices
   SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

   if (CurrentSenkouA() > CurrentSenkouB()
       && Latest_Price.ask < CurrentSenkouA() + POINT_GAP * Point()
       && Latest_Price.ask > CurrentSenkouA()) {

      return true;
   } else if (CurrentSenkouB() > CurrentSenkouA()
              && Latest_Price.ask < CurrentSenkouB() + POINT_GAP * Point()
              && Latest_Price.ask > CurrentSenkouB()) {

      return true;
   }
   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if buying                                                  |
//+------------------------------------------------------------------+
bool IsBuying()
{
// Check if Buy order currently exist
   for (int idx = 0; idx < PositionsTotal(); idx++) {
      PositionGetSymbol(idx);

      if (PositionGetString(POSITION_SYMBOL) == INPUT_SYMBOL
          && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
         return true;
      }
   }
   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if profit                                                  |
//+------------------------------------------------------------------+
bool IsProfit()
{
   MqlTick Latest_Price; // Structure to get the latest prices
   SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure

// Check if Buy order currently exist
   for (int idx = 0; idx < PositionsTotal(); idx++) {
      PositionGetSymbol(idx);

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double point = Point();
      
      if (PositionGetString(POSITION_SYMBOL) == INPUT_SYMBOL
          && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
          && Latest_Price.ask - openPrice >= 20 * point) {
         return true;
      }
   }
   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if Price Closed Above Cloud                                |
//+------------------------------------------------------------------+
bool IsPriceClosedAboveCloud(ENUM_TIMEFRAMES timeframe)
{
// Get previous close price
   double prev_close[2];
   CopyClose(INPUT_SYMBOL, timeframe, 0, 2, prev_close);

// If Green cloud and Open above cloud and Closed above cloud
   if (CurrentSenkouA() > CurrentSenkouB()
       && prev_close[0] > CurrentSenkouA()) {
      return true;
   }

// If Red cloud and Open above cloud and Closed above cloud
   if (CurrentSenkouB() > CurrentSenkouA()
       && prev_close[0] > CurrentSenkouB()) {
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if Chikou Above Price                                      |
//+------------------------------------------------------------------+
bool IsChikouAbovePrice(ENUM_TIMEFRAMES timeframe)
{
// Get previous open price
   double prev_open[28];
   CopyOpen(INPUT_SYMBOL, timeframe, 0, 28, prev_open);

// Get previous close price
   double prev_close[28];
   CopyClose(INPUT_SYMBOL, timeframe, 0, 28, prev_close);

// Chikou above bull price
   if (prev_open[0] > prev_close[0]
       && CurrentChikou() > prev_open[0]) {
      return true;
   }

// Chikou above bear price
   if (prev_close[0] > prev_open[0]
       && CurrentChikou() > prev_close[0]) {
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check if three falling stars                                     |
//+------------------------------------------------------------------+
bool IsThreeFall(ENUM_TIMEFRAMES timeframe)
{
// Get previous low price
   double prev_close[4];
   CopyClose(INPUT_SYMBOL, timeframe, 0, 4, prev_close);

   if (prev_close[3] < prev_close[2]
       && prev_close[2] < prev_close[1]
       && prev_close[1] < prev_close[0]) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if Tenkan cross Kijun from Above                           |
//+------------------------------------------------------------------+
bool IsTenkanCrossKijunFromAbove()
{
   if (CurrentTenkan() < CurrentKijun()
       && (CurrentTenkan(-1) > CurrentKijun(-1)
           || CurrentTenkan(-2) > CurrentKijun(-2)
           || CurrentTenkan(-3) > CurrentKijun(-3)
          )
      ) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+