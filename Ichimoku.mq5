//+------------------------------------------------------------------+
//| Ichimoku Function                                                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Filling indicator buffers from the iIchimoku indicator           |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double & tenkan_sen_buffer[],    // indicator buffer of the Tenkan-sen line
                           double & kijun_sen_buffer[],     // indicator buffer of the Kijun_sen line
                           double & senkou_span_A_buffer[], // indicator buffer of the Senkou Span A line
                           double & senkou_span_B_buffer[], // indicator buffer of the Senkou Span B line
                           double & chinkou_span_buffer[],  // indicator buffer of the Chinkou Span line
                           int ind_handle                   // handle of the iIchimoku indicator
                          )
{
// Shift of the Senkou Span lines in the future direction
   int senkou_span_shift = 26;
//--- reset error code
   ResetLastError();
//--- fill a part of the Tenkan_sen_Buffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle, 0, 0, amount, tenkan_sen_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("1.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Kijun_sen_Buffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle, 1, 0, amount, kijun_sen_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("2.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Chinkou_Span_Buffer array with values from the indicator buffer that has index 2
//--- if senkou_span_shift>0, the line is shifted in the future direction by senkou_span_shift bars
   if(CopyBuffer(ind_handle, 2, -senkou_span_shift, amount, senkou_span_A_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("3.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Senkou_Span_A_Buffer array with values from the indicator buffer that has index 3
//--- if senkou_span_shift>0, the line is shifted in the future direction by senkou_span_shift bars
   if(CopyBuffer(ind_handle, 3, -senkou_span_shift, amount, senkou_span_B_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("4.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the Senkou_Span_B_Buffer array with values from the indicator buffer that has 0 index
//--- when copying Chinkou Span, we don't need to consider the shift, since the Chinkou Span data
//--- is already stored with a shift in iIchimoku
   if(CopyBuffer(ind_handle, 4, 0, amount, chinkou_span_buffer) < 0) {
      //--- if the copying fails, tell the error code
      PrintFormat("5.Failed to copy data from the iIchimoku indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- everything is fine
   return(true);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Current Chikou Value                                         |
//+------------------------------------------------------------------+
double CurrentChikou(int shift = 0)
{
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - default_amount + shift;
   return Chikou_Span_Buffer[idx];
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Current Tenkan Value                                         |
//+------------------------------------------------------------------+
double CurrentTenkan(int shift = 0)
{
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - 1 + shift;
   return Tenkan_sen_Buffer[idx];
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Current Tenkan Value                                         |
//+------------------------------------------------------------------+
double CurrentKijun(int shift = 0)
{
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - 1 + shift;
   return Kijun_sen_Buffer[idx];
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Current Senkou Span A Value                                  |
//+------------------------------------------------------------------+
double CurrentSenkouA(int shift = 0)
{
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - default_amount + shift;
   return Senkou_Span_A_Buffer[idx];
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Current Senkou Span B Value                                  |
//+------------------------------------------------------------------+
double CurrentSenkouB(int shift = 0)
{
// Chikou index in chart: [old]...[new]
// [0] [1] [2] [3] [4] [5] [6]
   int idx = amount - default_amount + shift;
   return Senkou_Span_B_Buffer[idx];
}
//+------------------------------------------------------------------+
