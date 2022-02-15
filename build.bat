@echo off
set id=D0E8209F77C8CF37AD8BF550E51FF075
set arg=%1
set include_path=%APPDATA%\MetaQuotes\Terminal\%id%\MQL5
"C:\Program Files\MetaTrader 5\metaeditor64.exe" /compile:"%arg%" /include:"%include_path%"
exit 0