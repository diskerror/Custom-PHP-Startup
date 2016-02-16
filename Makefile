# Replace "project" with your own unique custom extension name.
# This will also be the namespace of some items in this extension.
EXTENSION_NAME = project
PHP_NAMESPACE = $(EXTENSION_NAME)
PROJECTPATH = /var/www/$(EXTENSION_NAME)

# Locations of all possible PHP classes used in your project or application.
# Below is a possible layout of a ZF1 application named "project"
#    with an additional Composer "vendor" directory.
# ** Composer autoload classes and Tests are ignored. **
# Paths may be absolute or relative to this file.
# All symbolic links are resolved to their absolute paths.
PHP_SEARCH_PATHS = \
	/var/www/ZendFramework/library/Zend \
	/var/www/ZendFramework/extras/library/ZendX \
	$(PROJECTPATH)/application \
	$(PROJECTPATH)/library \
	$(PROJECTPATH)/vendor


################################################################################
PHPE			= /etc/php5
EXTENSION_DIR	= $(shell php-config --extension-dir)
EXTENSION 		= $(EXTENSION_NAME).so
INI 			= $(EXTENSION_NAME).ini

COMPILER		= g++ -Wall -c -O2 -std=c++11 -fPIC -I/usr/local/include
LINKER			= g++ -shared

# This requires PHP-CPP to be installed on the host system.
LDLIBS = \
	-lphpcpp

CPP	= $(COMPILER) -include precompile.hpp $< -o $@

OBJECTS = \
	obj/RLess.o \
	obj/AutoloadValues.o \
	obj/Autoload.o \
	obj/main.o


################################################################################
# Build all dependencies.
all: $(EXTENSION)

pre: cleanall \
	obj/precompile.o

$(EXTENSION): obj/precompile.o $(OBJECTS)
	$(LINKER) $(OBJECTS) $(LDLIBS) -o $@

obj/precompile.o: precompile.hpp
	mkdir -p obj
	$(COMPILER) $< -o $@

# Create class-to-file map for this machine/instance.
#    Depends on data in this makefile.
AutoloadValues.cp: Makefile getClassFiles.php $(PHP_SEARCH_PATHS)
	./getClassFiles.php $(PHP_SEARCH_PATHS)

obj/RLess.o: RLess.cp RLess.h
	$(CPP)

obj/AutoloadValues.o: AutoloadValues.cp Autoload.h RLess.h
	$(CPP)

obj/Autoload.o: Autoload.cp Autoload.h RLess.h
	$(CPP)

obj/main.o: main.cp Autoload.h
	$(CPP) -D'EXTENSION_NAME="$(EXTENSION_NAME)"' -D'PHP_NAMESPACE="$(PHP_NAMESPACE)"' -D'PROJECTPATH="$(PROJECTPATH)"'


################################################################################
# Installation and cleanup. (tested on Debian 8 and CentOS 6)
install:
	cp -f $(EXTENSION) $(EXTENSION_DIR)
	chmod 644 $(EXTENSION_DIR)/$(EXTENSION)
	if [ -d /etc/php5/mods-available/ ]; then \
		echo "extension = "$(EXTENSION) > /etc/php5/mods-available/$(INI); \
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
		echo "extension = "$(EXTENSION) > /etc/php.d/$(INI);\
		chmod 644 /etc/php.d/$(INI);\
	fi
	if [ -d /etc/php-zts.d/ ]; then \
		echo "extension = "$(EXTENSION) > /etc/php-zts.d/$(INI);\
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
