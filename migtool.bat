echo off

SET PROPDIR=c:\dev\properties\
SET SAXON=c:\dev\tools\saxon9he.jar
SET DEFPACKAGEFILE=package.zip
SET METADATAIOBASE=c:\Dev\MetadataIO-M31

set P=%~dp0

set argC=0 
for %%x in (%*) do Set /A argC+=1

if %argC%==0 goto :usage

rem get the command called

SET ACT=%1

if /I NOT %ACT%==deploy if /I NOT %ACT%==retrieve if /I NOT %ACT%==cmp goto :usage

SETLOCAL ENABLEEXTENSIONS 
SETLOCAL EnableDelayedExpansion

if /I %ACT%==cmp goto :cmp %1 %2 %3 %4

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
		goto done
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
		 	ant -f %P%build.xml -propertyfile !PROPFILE! -Dpackagefile=!FETCHFILE! -Ddirname=%CD% retrieveUnpackaged
		 	for /F %%i IN (' dir /b retrieve* ') DO @(
		 	
		 		@if NOT "%4" == "" (
		 			@move /y %%i %4
		 		) else (
		 			@move /y %%i package.zip
		 		)
		 	)
		 	goto done
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
					echo Asked to run tests selectively: %5
					echo Customizing build.xml
					SET BUILDXML=build-output.xml
					java -jar %SAXON% -s:%P%build.xml -xsl:%P%addtests.xsl -o:%P%!BUILDXML! testclasses=%5 bldtarget=!BLDTARGET!
				)
				echo calling: ant -f %P%!BUILDXML! -propertyfile %PROPFILE% !DEPLOYTARGET! !BLDTARGET! !CHECKONLYSTRING!
			 	cmd /c "ant -f %P%!BUILDXML! -propertyfile %PROPFILE% !DEPLOYTARGET! !BLDTARGET! !CHECKONLYSTRING!"
			 	goto done
			)
		)
	) 
)

rem *********************************
rem Compare using MetadataIO
rem *********************************

:cmp

echo %*

IF NOT "%2" == "" (
	@rem check if it refers to a valid MetadataIO properties file
	IF NOT EXIST %METADATAIOBASE%\properties\build.properties.%2 (
		echo Could not locate %METADATAIOBASE%\properties\build.properties.%2 - aborting
		goto usage 
	) else (
		echo using %METADATAIOBASE%\properties\build.properties.%2 as comparison source
	)
) else (
	echo Could not locate parameter #2 - aborting
	goto usage
)

IF NOT "%3"=="" (
	rem check if it refers to a valid MetadataIO properties file
	IF NOT EXIST %METADATAIOBASE%\properties\build.properties.%3 (
		echo Could not locate %METADATAIOBASE%\properties\build.properties.%3 - aborting
		goto usage
	) else (
		echo using %METADATAIOBASE%\properties\build.properties.%3 as comparison target
	)
) else (
	echo Could not locate parameter #3 - aborting
	goto usage
)

if "%4"=="" (
	if EXIST %CD%\package.xml (
		echo Nothing provided to compare, but found %CD%\package.xml, will use that
		SET FETCHFILE=%CD%\package.xml
	)	
) else if not "%4"=="" (
	if EXIST "%4" (
		SET FETCHFILE=%4
	)
) else (
	echo Nothing provided to compare, and %CD%\package.xml not found, aborting
	goto usage
)
@echo cleaning %METADATAIOBASE%\repos\org\%2\ 
rmdir /q /s %METADATAIOBASE%\repos\org\%2\ 
mkdir %METADATAIOBASE%\repos\org\%2
@echo copying %FETCHFILE% to %METADATAIOBASE%\repos\org\%2\ 
copy %FETCHFILE% %METADATAIOBASE%\repos\org\%2 

@echo cleaning %METADATAIOBASE%\repos\org\%3\ 
rmdir /q /s %METADATAIOBASE%\repos\org\%3\ 
mkdir %METADATAIOBASE%\repos\org\%3\
@echo copying %FETCHFILE% to %METADATAIOBASE%\repos\org\%3\ 
copy %FETCHFILE% %METADATAIOBASE%\repos\org\%3 



SET CURDIR=%CD%
cd %METADATAIOBASE%
echo Fetching content from %2
cmd /c "multiretrieve %2"
echo Fetching content from %3
cmd /c "multiretrieve %3"
echo Running compare: localDiff.cmd %2 %3 all none
cmd /c "localDiff.cmd %2 %3 all none"
cd %CURDIR%
goto done


:usage
echo "usage: migtool retrieve <propertyfile> [<packagefile.xml>] [<outputfilename>]"
echo "usage: migtool deploy <propertyfile> [<directoryname>] [checkonly|d] ["testclass1,testclass2"]" 
echo "usage: migtool compare <sourcepropertyfile> <targetpropertyfile> [<packagefile.xml>]"
:done

ENDLOCAL 

