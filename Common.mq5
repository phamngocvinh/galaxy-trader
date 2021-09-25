//+------------------------------------------------------------------+
//| Get Timeframe Second                                             |
//+------------------------------------------------------------------+
int getTimeframeSecond (ENUM_TIMEFRAMES timeframe)
{
   if (PERIOD_M1 == timeframe) {
      return 60;
   } else if (PERIOD_M5 == timeframe) {
      return 300;
   } else if (PERIOD_M15 == timeframe) {
      return 900;
   } else if (PERIOD_M30 == timeframe) {
      return 1800;
   } else if (PERIOD_H1 == timeframe) {
      return 3600;
   } else if (PERIOD_H4 == timeframe) {
      return 14400;
   } else if (PERIOD_D1 == timeframe) {
      return 43200;
   }
   return 0;
}
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
