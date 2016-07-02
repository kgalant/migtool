# migtool #
## Force.com migration tool wrapper ##

Very simple readme here... An actual brief manual, etc. will follow

This is a Windows batch wrapper for the force.com migration tool that abstracts away a lot of the complexity of putting together org properties files, build.xmls and such to enable easy access to a couple of commonly used functions of the Force.com ANT tool.
Usage is as follows:


	migtool retrieve propertyfile [packagefile.xml] [outputfilename]
	migtool deploy propertyfile [directoryname|packagename.zip] [checkonly|d] ["testclass1,testclass2"]

So fairly straightforward:

### retrieve ###

For the org referred to in the given propertyfile: 

* if a package filename is provided and and outputfilename is provided, fetch the packagefile and save as the output filename (will always produce a zip, so calling it something other can be kinda counterproductive)
* if an outputfilename isn't provided, will use whatever the default package filename is (line 5 of migtool.bat)
* if a packagefile.xml name isn't provided, will look for package.xml, and try to get that from the org

So, create a directory containing a valid package.xml file, then call migtool retrieve *orgname* in that directory. If a *orgname*.properties file can be located in the configured property directory (see below), migtool will attempt to fetch that package.xml and produce a package.zip file with the results.

### deploy ###

For the org in the property file:

* will try to deploy the directory or zip provided. If nothing is provided, will try the default package name (set in line 5 of migtool.bat)
* if checkonly is given after the whatever to deploy, it will validate only - any other parameter here (or lack of anything after the item to deploy) will mean do a real deployment
* any testclasses provided (if more than one then in double quotes, comma-separated, no extra spaces) as the last parameter mean run these test classes only (only for fairly recent API versions >=34)

Remember, this is basically DOS, so if you want to provide e.g. specific test classes to run, you have to provide it with the previous parameters, even if you're happy with the defaults
So,	`migtool deploy *orgname*`
will deploy the package.zip file from your current directory into the *orgname* org
But, if you want to do it running the test class *MyTestClass*, you have to give it this command: `migtool deploy *orgname* package.zip d MyTestClass`.

Great shoutout to DOS for not having a way of parsing parameters that doesn't make you want to shoot yourself!!! 

Bonus: remember, you can chain commandline commands, so something like this:`migtool retrieve mydevorg &amp; migtool deploy mytestorg` will pick up a package.xml file in your current directory, retrieve it from the *mydevorg* org and deploy it to *mytestorg* all in one fell swoop.



###### Required dependecies (not in this repo): 
* Saxon XSLT parser jar file
* ant-salesforce.jar (from Force.com migration tool installation package)

###### Required installation/path setup:
* Put some SFDC properties files in a directory. Properties files look like this:

		username=user@password.com
		password=T0ps3cr3t
		serverurl=https://login.salesforce.com
		maxPoll=20000
		pollWaitMillis=10000
		apiversion=37.0

	The file name is *orgname*.properties, where *orgname* is what you will plug in to the commandline above as *&lt;propertyfile&gt;*
* Tell migtool where that directory is: change line 3 of migtool.bat to point to the properties dir
* Make sure your ant and the migtool directory are both in the path
* Tell migtool where the Saxon jar file is (line 4 of migtool.bat)
* copy/symlink a current ant-salesforce.jar into the migtool directory 