# migtool #
## migtool Force.com migration tool wrapper ##

Very simple readme here... An actual brief manual, etc. will follow

This is a Windows batch wrapper for the force.com migration tool that abstracts away a lot of the complexity of putting together org properties files, build.xmls and such to enable easy access to a couple of commonly used functions of the Force.com ANT tool.
Usage is as follows:


* migtool retrieve &lt;propertyfile&gt; [&lt;packagefile.xml&gt;] [&lt;outputfilename&gt;]
* migtool deploy &lt;propertyfile&gt; [&lt;directoryname&gt;] [checkonly|d] ["testclass1,testclass2"]
* migtool compare &lt;sourcepropertyfile&gt; &lt;targetpropertyfile&gt; [&lt;packagefile.xml&gt;]

More of a manual to follow

Required dependecies (not in this repo): 
* Saxon XSLT parser jar file
* ant-salesforce.jar (from Force.com migration tool installation package)

Required installation/path setup:
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