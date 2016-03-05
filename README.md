# Custom Startup Extension
This PHP extension assists the moving of typical PHP script startup routines and configuration data into a PHP extension (.so) where they are ready to be used (M INIT) before a web script is run (R INIT). This project was set up so that customizing the data need only be performed in one place even if they are needed in more than one file.

## Features

### Autoloader Data
Class autoloading with the ```project\get_autoload_file()``` function is 2%-15% faster than typical PHP autoloaders depending on PHP and framework version. Choose the class search paths in the makefile, compile, and use this code at the project entry point, i.e. ```index.php```:
```
spl_autoload_register(function($class) {
    if ( $file = project\get_autoload_file($class) ) {
        include $file;
    }
});
```


### Hard Coded Constants
Regular PHP "defines" can be compiled into the extension where they are ready to be used making it unnecessary to recreate them each time a script is run.

### INI Namespace Constants
Aids in the creation of "php.ini" file values for retrieval with ```$v1 = ini_get('project.var1');```. These are about seven times slower than the "defines" above but are useful when values need to be changed often and recompiling this extension is not convienent.

## Requirements For Compiling
GCC, Make, and the standard libraries are required to build and install the custom extension, as is the PHP development libraries, and the Copernica [PHP-CPP](http://www.phpcpp.com) API installed with the command ```make release``` rather than just ```make``` which creates a version for debugging.

CentOS 6 requires at least devtoolset-2 to compile PHP-CPP.
```
 > cd /etc/yum.repos.d
 > wget http://people.centos.org/tru/devtools-2/devtools-2.repo
 > yum --enablerepo=testing-devtools-2-centos-6 install devtoolset-2-gcc devtoolset-2-gcc-c++
 > scl enable devtoolset-2 bash
```

