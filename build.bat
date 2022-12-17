del /q bin\*.exe
cd source
for %%f in (*.lpi) do c:\lazarus\lazbuild --build-all --build-mode=release --no-write-project %%f
cd ..
