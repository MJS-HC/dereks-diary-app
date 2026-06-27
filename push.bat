REM Run from Claude Code with: ! .\push.bat
REM You need to be in the correct folder
@echo off
cd "C:\ClaudeCode\Dereks Diary App"
git add .
git commit -m "Deploy update"
git push
pause
