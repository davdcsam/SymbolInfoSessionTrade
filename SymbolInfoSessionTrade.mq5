//+------------------------------------------------------------------+
#include "Setting.mqh"
#include "Inputs.mqh"
#include <errordescription.mqh>

//+------------------------------------------------------------------+
class SessionInfo
  {
public:
                     SessionInfo() {};
                    ~SessionInfo() {};

   datetime          date;
   datetime          closeTime;

   const SessionInfo *Clone()
     {
      SessionInfo *temp = new SessionInfo();
      temp.date = date;
      temp.closeTime = closeTime;
      return temp;
     }
  };

SessionInfo sessions[];

//+------------------------------------------------------------------+
int OnInit(void)
  {
   MqlTick ticks[];
// Get ticks for the current day
   int tickCount = CopyTicksRange(_Symbol, ticks, COPY_TICKS_TIME_MS, inpDtStart * 1000, inpDtEnd * 1000);
   if(tickCount <= 0)
     {
      Print("Failed to get ticks for ", TimeToString(inpDtStart), " to ", TimeToString(inpDtEnd)," Error: ", ErrorDescription(GetLastError()));
      return INIT_FAILED;
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
      SessionInfo session;
      session.date = currentDate;
      session.closeTime = lastTickTime;
      ArrayResize(sessions, ArraySize(sessions) + 1);
      sessions[ArraySize(sessions) - 1] = session;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string filename;
   int fileHandle;
   if(inpFilesCommon)
     {
      FolderCreate(__FILE__, FILE_COMMON);
      filename = __FILE__+"//"inpFileName + ".csv";
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
      return;
     }

   FileWrite(fileHandle, "Date", "Close Time");
   for(int i = 0; i < ArraySize(sessions); i++)
     {
      FileWrite(fileHandle,
                TimeToString(sessions[i].date),
                TimeToString(sessions[i].closeTime)
               );
     }
   FileClose(fileHandle);
  }
//+------------------------------------------------------------------+
