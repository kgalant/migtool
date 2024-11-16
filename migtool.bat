@echo off

SET PROPDIR=c:\dev\properties\
SET SAXON=c:\dev\tools\saxon9he.jar
SET DEFPACKAGEFILE=package.zip
SET UNZIP=c:\dev\tools\7zip\7za.exe

set P=%~dp0

set argC=0 
for %%x in (%*) do Set /A argC+=1

if %argC%==0 goto :usage

rem get the command called

SET ACT=%1

if /I NOT %ACT%==deploy if /I NOT %ACT%==retrieve if /I NOT %ACT%==transfer goto :usage

SETLOCAL ENABLEEXTENSIONS 
SETLOCAL EnableDelayedExpansion

if /I %ACT%==transfer goto :transfer %1 %2 %3 %4 %5 %6

rem *********************************
rem Common for both deploy & retrieve
rem *********************************


IF EXIST %2 (
	SET PROPFILE=%2
) else (
	IF EXIST %PROPDIR%%2.properties (
		SET PROPFILE=%PROPDIR%%2.properties
	) else (
		echo Couldn't find property file %2 or locate a %PROPDIR%%2.properties file, aborting...
		exit /b 1

	)
)

if NOT "%PROPFILE%" == "" (
	IF /I "%ACT%" == "retrieve" (
		if "%3" == "" (
			IF EXIST %CD%\package.xml (
				SET FETCHFILE=%CD%\package.xml
			) 
		) else (
			SET FETCHFILE=%3
		)

		if NOT "%4" == "" (
			SET OUTPUTFILE=%4
		) else (
			SET OUTPUTFILE=package.zip
		)
		if NOT "!FETCHFILE!" == "" (
			echo Retrieving !FETCHFILE! using !PROPFILE! into !OUTPUTFILE!
		 	cmd /c "ant -f %P%build.xml -propertyfile !PROPFILE! -Dpackagefile=!FETCHFILE! -Ddirname=%CD% retrieveUnpackaged"
		 	for /F %%i IN (' dir /b retrieve* ') DO @(
		 	
		 		@if NOT "%4" == "" (
		 			@move /y %%i %4 > NUL
		 		) else (
		 			@move /y %%i package.zip > NUL
		 		)
		 	)
			exit /b
	 	)
	) 

	IF /I "%ACT%" == "deploy" (

		if "%3" == "" (
			if EXIST %DEFPACKAGEFILE% (
				echo Nothing provided to deploy, but %DEFPACKAGEFILE% found, will deploy that
				SET FETCHFILE=%CD%\%DEFPACKAGEFILE%
				SET BLDTARGET=deployZip
				SET DEPLOYTARGET=-Dfilename=!FETCHFILE!
			) else (
				if EXIST %CD%\package.xml (
					echo Nothing provided to deploy, %CD%\%DEFPACKAGEFILE% was not found, but found %CD%\package.xml, will deploy that
					SET FETCHFILE=%CD%
					SET BLDTARGET=deployDir
					SET DEPLOYTARGET=-DdeployRoot=!FETCHFILE!
				)
			)	
		) else (
			SET FETCHFILE=%3
			IF EXIST %3\NUL (
				SET BLDTARGET=deployDir
				SET DEPLOYTARGET=-DdeployRoot=!FETCHFILE!
			) else (
				SET BLDTARGET=deployZip
				SET DEPLOYTARGET=-Dfilename=!FETCHFILE!
			)
		)

		if "%4" == "checkonly" (
			SET CHECKONLYSTRING=-DcheckOnly=true
		)

		if "%PROPFILE%" neq "" (
			if NOT "!FETCHFILE!" == "" (
				SET BUILDXML=build.xml
				echo Asked to deploy !FETCHFILE! using %PROPFILE% !CHECKONLYSTRING!

				if NOT [%5] == [] (
					if "%5" == "findtests" (

						echo Asked to find tests in !FETCHFILE!
						echo:
						rem Get Package.xml first
						if "%BLDTARGET%" == "deployDir" (
							rem If deploying a directory, it's simple
							SET PACKAGEXML = !FETCHFILE!\package.xml
						) else (
							rem if deploying a zip, need to unzip, get the package.xml processed, then delete it again
							mkdir .\migtooltemp
							cmd /c "%UNZIP% e !FETCHFILE! package.xml -o.\migtooltemp > NUL"
						)

						FOR /F "tokens=* USEBACKQ" %%F IN (`"java -jar %SAXON% -s:.\migtooltemp\package.xml -xsl:%P%findtests.xsl -warnings:silent"`) DO (
							SET TESTNAMES=%%F
						)
						rd /s /q .\migtooltemp
					) else (
						SET TESTNAMES=%5
					)

					echo Asked to run tests selectively: !TESTNAMES!
					echo:
					echo Customizing build.xml
					SET BUILDXML=build-output.xml
					java -jar %SAXON% -s:%P%build.xml -xsl:%P%addtests.xsl -o:%P%!BUILDXML! testclasses=!TESTNAMES! bldtarget=!BLDTARGET!
					echo:
				)

				echo calling: ant -f %P%!BUILDXML! -propertyfile %PROPFILE% !DEPLOYTARGET! !BLDTARGET! !CHECKONLYSTRING!
			 	cmd /c "ant -f %P%!BUILDXML! -propertyfile %PROPFILE% !DEPLOYTARGET! !BLDTARGET! !CHECKONLYSTRING!"
			 	exit /b
			)
		)
	) 
)

:transfer

rem parameters:
rem %1:transfer %2:sourcepropertyfile %3:targetpropertyfile %4:packagefile.xml %5:checkonly|d %6:testclass1,testclass2

cls
echo Asked to transfer %4 from %2 to %3. 
if "%5" == "checkonly" echo validate only: true
if NOT "%6" == "" echo test classes to run: %6
echo: 

rem *********************************
rem Set property file for source
rem *********************************

IF EXIST %2 (
	SET FROMFILE=%2
) else (
	IF EXIST %PROPDIR%%2.properties (
		SET FROMFILE=%PROPDIR%%2.properties
	) else (
		echo Couldn't find property file %2 or locate a %PROPDIR%%2.properties file, aborting...
		exit /b 1
	)
)

rem *********************************
rem Set property file for destination
rem *********************************

IF EXIST %3 (
	SET TOFILE=%3
) else (
	IF EXIST %PROPDIR%%3.properties (
		SET TOFILE=%PROPDIR%%3.properties
	) else (
		echo Couldn't find property file %3 or locate a %PROPDIR%%3.properties file, aborting...
		exit /b 1
	)
)

rem *********************************
rem Do the deed
rem *********************************

echo calling retrieve: migtool retrieve %2 %4 transferpackage.zip
echo:
cmd /c "migtool retrieve %2 %4 transferpackage.zip"
IF %ERRORLEVEL% EQU 0 (
	echo calling deploy: migtool deploy %2 transferpackage.zip %5 %6
	echo: 
	cmd /c "migtool deploy %3 transferpackage.zip %5 %6"
)

exit /b

:usage
echo "usage: migtool retrieve <propertyfile> [<packagefile.xml>] [<outputfilename>]"
echo "usage: migtool deploy <propertyfile>/<directoryname> [checkonly|d] ["testclass1,testclass2"|findtests]" 
echo "usage: migtool transfer <sourcepropertyfile> <targetpropertyfile> [<packagefile.xml>] [checkonly|d] ["testclass1,testclass2"|findtests]"
echo "parameters can only be omitted from the end - all parameters up to the last one you want to provide must be provided." 
echo "E.g. testclass parameter ["testclass1,testclass2"] can be skipped, but if you want to use it, you must provide a [checkonly|d] value"
echo "findtests parameter provided last (instead of comma-separated test class names) will get migtool to look through the package being deployed and add any class name ending with _Test (case-sensitive) to list of tests to run"
:done

exit

ENDLOCAL 

