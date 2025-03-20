//+------------------------------------------------------------------+
#include "Setting.mqh"
#include "Inputs.mqh"
#include <errordescription.mqh>

//+------------------------------------------------------------------+
#property icon "res/sistfamily.ico"
#property script_show_inputs true

//+------------------------------------------------------------------+
datetime closeTimes[];

//+------------------------------------------------------------------+
int OnStart(void)
  {
   MqlTick ticks[];
// Get ticks for the current day
   int tickCount = CopyTicksRange(_Symbol, ticks, COPY_TICKS_TIME_MS, inpDtStart * 1000, inpDtEnd * 1000);
   if(tickCount <= 0)
     {
      Print("Failed to get ticks for ", TimeToString(inpDtStart), " to ", TimeToString(inpDtEnd)," Error: ", ErrorDescription(GetLastError()));
      return 0;
     }

// Process ticks day by day to find closing times
   datetime currentDate = 0;
   datetime lastTickTime = 0;

   for(int i = 0; i < tickCount; i++)
     {
      datetime tickDate = ticks[i].time;
      MqlDateTime tickStruct;
      TimeToStruct(tickDate, tickStruct);
      tickStruct.hour = 0;
      tickStruct.min = 0;
      tickStruct.sec = 0;
      datetime normalizedDate = StructToTime(tickStruct);

      // If we've moved to a new day, save the last tick time of previous day
      if(normalizedDate != currentDate && currentDate != 0 && lastTickTime != 0)
        {
         ArrayResize(closeTimes, ArraySize(closeTimes) + 1);
         closeTimes[ArraySize(closeTimes) - 1] = lastTickTime;
         lastTickTime = 0;
        }

      // Update tracking variables
      currentDate = normalizedDate;
      if(ticks[i].time > lastTickTime)
        {
         lastTickTime = ticks[i].time;
        }
     }

// Don't forget to save the last day's closing time
   if(lastTickTime != 0)
     {
      ArrayResize(closeTimes, ArraySize(closeTimes) + 1);
      closeTimes[ArraySize(closeTimes) - 1] = lastTickTime;
     }

   string filename;
   int fileHandle;
   if(inpFilesCommon)
     {
      Print(StringFind(inpFileName, ".csv"));
      Print(StringLen(inpFileName) - 4);
      FolderCreate(__FILE__, FILE_COMMON);
      filename = __FILE__+
                 "/"+
                 ((StringFind(inpFileName, ".csv") == StringLen(inpFileName) - 4) ? inpFileName : StringSubstr(inpFileName, 0, StringLen(inpFileName) - 4)) +
                 StringFormat("%s-%s", TimeToString(inpDtStart, TIME_DATE), TimeToString(inpDtEnd, TIME_DATE)) +
                 ((StringFind(inpFileName, ".csv") == StringLen(inpFileName) - 4) ? "" : ".csv");
      fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON, CharToString(44));
     }
   else
     {
      FolderCreate(__FILE__);
      filename = inpFileName +
                 StringFormat("%s-%s", TimeToString(inpDtStart, TIME_DATE), TimeToString(inpDtEnd, TIME_DATE)) +
                 ((StringFind(inpFileName, ".csv") == StringLen(inpFileName) - 4) ? "" : ".csv");
      fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI, CharToString(44));
     }

   if(fileHandle == INVALID_HANDLE)
     {
      Print("Failed to open file: ", ErrorDescription(GetLastError()));
      return 0;
     }

   FileWrite(fileHandle, "Date", "Close Time");
   for(int i = 0; i < ArraySize(closeTimes); i++)
     {
      FileWrite(fileHandle,
                TimeToString(closeTimes[i], TIME_DATE),
                TimeToString(closeTimes[i], TIME_MINUTES | TIME_SECONDS)
               );
     }
   FileClose(fileHandle);
   return 1;
  }
//+------------------------------------------------------------------+
