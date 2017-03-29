set dd=%date:~0,4%%date:~5,2%%date:~8,2%
set filename=%dd%_source.zip
rem echo %filename%
git archive --format=zip HEAD > %filename%
