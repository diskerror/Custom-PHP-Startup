# Replace "project" with your own unique custom extension name.
# This will also be the namespace of some items in this extension.
EXTENSION_NAME	= project

# Locations of all possible PHP classes used in your project or application.
# Below is a possible layout of a ZF1 application named "project"
#    with an additional Composer "vendor" directory.
#    [[ Composer autoload classes are ignored ]]
# Paths may be absolute or relative to this file.
# Bad paths will be skipped and message will be displayed.
PHP_SEARCH_PATHS = \
	/var/www/ZendFramework/library/Zend \
	/var/www/ZendFramework/extras/library/ZendX \
	/var/www/$(EXTENSION_NAME)/application \
	/var/www/$(EXTENSION_NAME)/library \
	/var/www/$(EXTENSION_NAME)/vendor


################################################################################
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
	obj/Autoload.o \
	obj/main.o


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
#    Depends on data in this file.
AutoloadValues.cp: Makefile getClassFiles.php
	./getClassFiles.php $(PHP_SEARCH_PATHS)

obj/MurmurHash3.o: MurmurHash3.cpp MurmurHash3.h
	$(CPP)

obj/Hash.o: Hash.cp Hash.h MurmurHash3.h
	$(CPP)

obj/Autoload.o: Autoload.cp AutoloadValues.h Hash.h
	$(CPP)

obj/AutoloadValues.o: AutoloadValues.cp AutoloadValues.h Hash.h
	$(CPP)

obj/main.o: main.cp AutoloadValues.h
	$(CPP) -D'EXTENSION_NAME="$(EXTENSION_NAME)"'


################################################################################
# Installation and cleanup. (tested on Debian 8 and CentOS 6)
install:
	cp -f $(EXTENSION) $(EXTENSION_DIR)
	chmod 644 $(EXTENSION_DIR)/$(EXTENSION)
	if [ -d /etc/php5/mods-available/ ]; then \
		echo "extension = "$(EXTENSION)"\n" > /etc/php5/mods-available/$(INI); \
		chmod 644 /etc/php5/mods-available/$(INI); \
		if [ -d /etc/php5/apache2/conf.d/ ]; then \
			ln -sf /etc/php5/mods-available/$(INI) /etc/php5/apache2/conf.d/; \
		fi; \
		if [ -d /etc/php5/cli/conf.d/ ]; then \
			ln -sf /etc/php5/mods-available/$(INI) /etc/php5/cli/conf.d/; \
		fi; \
		if [ -d /etc/php5/cgi/conf.d/ ]; then \
			ln -sf /etc/php5/mods-available/$(INI) /etc/php5/cgi/conf.d/; \
		fi; \
	fi
	if [ -d /etc/php.d/ ]; then \
		echo "extension = "$(EXTENSION)"\n" > /etc/php.d/$(INI);\
		chmod 644 /etc/php.d/$(INI);\
	fi
	if [ -d /etc/php-zts.d/ ]; then \
		echo "extension = "$(EXTENSION)"\n" > /etc/php-zts.d/$(INI);\
		chmod 644 /etc/php-zts.d/$(INI);\
	fi

uninstall:
	rm -f $(EXTENSION_DIR)/$(EXTENSION)
	find /etc/php5 -name $(INI) | xargs rm -f
	rm -f /etc/php.d/$(INI) /etc/php-zts.d/$(INI)
		
clean:
	rm -f $(EXTENSION) $(OBJECTS) AutoloadValues.cp

# remove all objects including precompiled header
cleanall:
	rm -rf $(EXTENSION) obj/* obj AutoloadValues.cp
