# migtool
migtool Force.com migration tool wrapper

Very simple readme here... An actual brief manual, etc. will follow

This is a Windows batch wrapper for the force.com migration tool that abstracts away a lot of the complexity of putting together org properties files, build.xmls and such to enable easy access to a couple of commonly used functions of the Force.com ANT tool.
Usage is as follows:


usage: migtool retrieve <propertyfile> [<packagefile.xml>] [<outputfilename>]
usage: migtool deploy <propertyfile> [<directoryname>] [checkonly|d] ["testclass1,testclass2"]
usage: migtool compare <sourcepropertyfile> <targetpropertyfile> [<packagefile.xml>]

More of a manual to follow
