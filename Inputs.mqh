//+------------------------------------------------------------------+
input group "Time Range"

input datetime inpDtStart = D'2025.01.01 00:00:00'; // Start

input datetime inpDtEnd = D'2026.01.01 00:00:00'; // End

input group "File Destination";

input string inpFileName = "example"; // File Name

input bool inpFilesCommon = true; // Save in Common/Files
//+------------------------------------------------------------------+
