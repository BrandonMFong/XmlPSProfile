# This is an include file for the other makefiles

TOOLS = \
	enumdir \
	exist \
	selectitem \
	getpath \
	cat \
	getdir \
	query \
	json \
	configReader \
	homePath

# Ascend object hierarchy
FILESYSTEM = \
	xAppPointer \
	xConfigReader \
	xXml \
	xJson \
	xAppSettings \
	xFile \
	xDirectory 

SQL = \
	xDatabase \
	xQuery 

XPRO = \
	xPro \
	xObject \
	xArguments

EXTERN = \
	pugixml.cpp \
	sqlite3.c 

OBJECTS = $(XPRO) $(SQL) $(FILESYSTEM)

all: $(EXTERN) $(OBJECTS) $(TOOLS) clean

lib: debug $(EXTERN) $(OBJECTS)
