# Replace "project" with your own custom extension name.
EXTENSION_NAME	= project

PHPE			= /etc/php5
EXTENSION_DIR	= $(shell php-config --extension-dir)
EXTENSION 		= $(EXTENSION_NAME).so
INI 			= $(EXTENSION_NAME).ini

COMPILER		= g++
LINKER			= g++
COMPILER_FLAGS	= -Wall -c -O2 -std=c++11 -fPIC -I/usr/local/include
LINKER_FLAGS	= -shared

# This requires PHP-CPP to be installed on the host system.
LDLIBS = \
	-lphpcpp

CPP	= $(COMPILER) $(COMPILER_FLAGS) -include precompile.hpp $< -o $@

OBJECTS = \
	obj/MurmurHash3.o \
	obj/Hash.o \
	obj/AutoloadValues.o \
	obj/AutoloadGet.o \
	obj/main.o

# Locations of all possible PHP classes used in a project or application.
# Below is a possible layout of a ZF1 application
#    with an additional Composer "vendor" directory.
#    Paths may be absolute or relative to this file.
PHP_SEARCH_PATHS = \
	/var/www/ZendFramework/library/Zend \
	/var/www/ZendFramework/extras/library/ZendX \
	/var/www/project/application \
	/var/www/project/library \
	/var/www/project/vendor


################################################################################
# Build all dependencies.
all: $(EXTENSION)

pre: cleanall \
	obj/precompile.o

$(EXTENSION): obj/precompile.o $(OBJECTS)
	$(LINKER) $(OBJECTS) $(LINKER_FLAGS) $(LDLIBS) -o $@

obj/precompile.o: precompile.hpp
	mkdir -p obj
	$(COMPILER) $(COMPILER_FLAGS) $< -o $@

# Create class-to-file map for this machine/instance.
AutoloadValues.cp: Makefile getClassFiles.php
	./getClassFiles.php $(PHP_SEARCH_PATHS)

obj/MurmurHash3.o: MurmurHash3.cpp MurmurHash3.h
	$(CPP)

obj/Hash.o: Hash.cp Hash.h MurmurHash3.h
	$(CPP)

obj/AutoloadGet.o: AutoloadGet.cp AutoloadValues.h Hash.h
	$(CPP)

obj/AutoloadValues.o: AutoloadValues.cp AutoloadValues.h Hash.h
	$(CPP)

obj/main.o: main.cp AutoloadValues.h
	$(CPP) -D'EXTENSION_NAME="$(EXTENSION_NAME)"'


################################################################################
# Installation and cleanup. (tested on Debian 8)
install:
	cp -f $(EXTENSION) $(EXTENSION_DIR)
	chmod 644 $(EXTENSION_DIR)/$(EXTENSION)
	echo "extension = "$(EXTENSION)"\n" > $(PHPE)/mods-available/$(INI)
	chmod 644 $(PHPE)/mods-available/$(INI)
	if [ -d $(PHPE)/apache2/conf.d/ ]; then \
		ln -sf $(PHPE)/mods-available/$(INI) $(PHPE)/apache2/conf.d/;\
	fi
	if [ -d $(PHPE)/cli/conf.d/ ]; then \
		ln -sf $(PHPE)/mods-available/$(INI) $(PHPE)/cli/conf.d/;\
	fi
	if [ -d $(PHPE)/cgi/conf.d/ ]; then \
		ln -sf $(PHPE)/mods-available/$(INI) $(PHPE)/cgi/conf.d/;\
	fi

uninstall:
	rm -f $(EXTENSION_DIR)/$(EXTENSION)
	find $(PHPE) -name $(INI) | xargs rm -f
		
clean:
	rm -f $(EXTENSION) $(OBJECTS) AutoloadValues.cp

# remove all objects including precompiled header
cleanall:
	rm -rf $(EXTENSION) obj/* obj AutoloadValues.cp
