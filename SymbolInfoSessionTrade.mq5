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

// Find the last tick of the day which represents the closing time
   datetime lastTickTime = 0;
   for(int i = 0; i < tickCount; i++)
     {
      if(ticks[i].time > lastTickTime)
        {
         lastTickTime = ticks[i].time;
        }
     }

   if(lastTickTime > 0)
     {
      ArrayResize(closeTimes, ArraySize(closeTimes) + 1);
      closeTimes[ArraySize(closeTimes) - 1] = lastTickTime;
     }

   string filename;
   int fileHandle;
   if(inpFilesCommon)
     {
      FolderCreate(__FILE__, FILE_COMMON);
      filename = __FILE__+"/"+inpFileName + ".csv";
      fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
     }
   else
     {
      FolderCreate(__FILE__);
      filename = inpFileName + ".csv";
      fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI);
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
