# makefile
# https://docs.microsoft.com/en-us/cpp/build/reference/description-blocks?view=msvc-160
# https://www.bojankomazec.com/2011/10/how-to-use-nmake-and-makefile.html

include ..\makefile

# MACROS START
CC=cl
LINK=link
SOURCE_ROOT=.\..\..\..\Sources
xPro_ROOT=$(SOURCE_ROOT)\..
TOOLS_DIR=$(SOURCE_ROOT)\Tools
FRAMEWORK_DIR=$(SOURCE_ROOT)\xPro
BIN_DIR=$(xPro_ROOT)\bin
FLAGS = \
	/std:c++17 \
	/EHsc \
	/I$(SOURCE_ROOT) \
	/D_CRT_SECURE_NO_WARNINGS=1
# MACROS end

debug : 
    FLAGS += /g
    CLANGFLAGS += /g

$(TOOLS) : 
	@echo xPro Tools: $@ 
	@$(CC) /c $(TOOLS_DIR)\$@\main.cpp $(FLAGS) 
	@$(LINK) /out:$(BIN_DIR)\xpro.$@.exe *.obj 

$(EXTERN) : 
	@echo Package: $@ 
	@$(CC) /c $(FRAMEWORK_DIR)\extern\$@ /Fe$@.obj $(FLAGS)

$(OBJECTS) :
	@echo xPro Objects: $@
	@$(CC) /c $(FRAMEWORK_DIR)\$@.cpp /Fe$@.obj $(FLAGS)

clean :
	@echo Cleaning...
	@del *.obj
