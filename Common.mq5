//+------------------------------------------------------------------+
//| Common Function                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check if valid symbol                                            |
//+------------------------------------------------------------------+
bool isValidSymbol ()
{
   if(!SymbolSelect(INPUT_SYMBOL, true)) {
      Print("Invalid symbol!");
      ExpertRemove();
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if Price Closed Above Cloud                                |
//+------------------------------------------------------------------+
bool IsPriceClosedAboveCloud()
{
// Get previous open price
   double prev_open[2];
   CopyOpen(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 2, prev_open);

// Get previous close price
   double prev_close[2];
   CopyClose(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 2, prev_close);

// If Green cloud and Open above cloud and Closed above cloud
   if (CurrentSenkouA() > CurrentSenkouB()
       && prev_open[0] > CurrentSenkouA()
       && prev_close[0] > CurrentSenkouA()) {
       Print("Price above Green cloud");
      return true;
   }

// If Red cloud and Open above cloud and Closed above cloud
   if (CurrentSenkouB() > CurrentSenkouA()
       && prev_open[0] > CurrentSenkouB()
       && prev_close[0] > CurrentSenkouB()) {
       Print("Price above Red cloud");
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if Chikou Above Price                                      |
//+------------------------------------------------------------------+
bool IsChikouAbovePrice()
{
// Get previous open price
   double prev_open[28];
   CopyOpen(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 28, prev_open);

// Get previous close price
   double prev_close[28];
   CopyClose(INPUT_SYMBOL, INPUT_TIMEFRAME, 0, 28, prev_close);

// Chikou above bull price
   if (prev_open[0] > prev_close[0]
       && CurrentChikou() > prev_open[0]) {

      Print("Chikou above Price");
      return true;
   }

// Chikou above bear price
   if (prev_close[0] > prev_open[0]
       && CurrentChikou() > prev_close[0]) {

      Print("Chikou above Price");
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
