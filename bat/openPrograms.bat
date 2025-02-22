@echo off
REM Start Telegram
if exist "C:\Users\Parth\AppData\Roaming\Telegram Desktop\Telegram.exe" (
    start "Telegram" "C:\Users\Parth\AppData\Roaming\Telegram Desktop\Telegram.exe"
)

REM Start Spotify
start Spotify

REM Start Slack
if exist "C:\Users\Parth\AppData\Local\slack\slack.exe" (
    start "Slack" "C:\Users\Parth\AppData\Local\slack\slack.exe"
)

REM Start Signal
if exist "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" (
    start "Signal" "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Signal.lnk"
)

REM Start Gmail (Chrome App)
if exist "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Gmail.lnk" (
    start "Gmail" "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Gmail.lnk"
)

REM Start WorkMail (Chrome App)
if exist "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\WorkMail.lnk" (
    start "WorkMail" "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\WorkMail.lnk"
)


REM Start ChatGPT
if exist "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\ChatGPT.lnk" (
    start "ChatGPT" "C:\Users\Parth\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\ChatGPT.lnk"
)

REM Wait for 2 seconds
timeout 2 >nul

exit
