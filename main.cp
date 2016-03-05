
#include "Autoload.h"

using namespace std;

extern "C" {

/**
 *  Function that is called by PHP right after the PHP process
 *  has started, and that returns an address of an internal PHP
 *  strucure with all the details and features of your extension
 *
 *  @return void*   a pointer to an address that is understood by PHP
 */
PHPCPP_EXPORT void *get_module() 
{
	// static(!) Php::Extension object that should stay in memory
	// for the entire duration of the process (that's why it's static)
	// The parameters are a string for the extension name and a string for the version.
	static Php::Extension extension(EXTENSION_NAME, "0.0");
	
	//	These work the same as PHP: define('PROJECT_PATH', '/var/www/project');
	extension.add(Php::Constant("PROJECT_PATH", PROJECTPATH));
	extension.add(Php::Constant("APPLICATION_PATH", PROJECTPATH "/application"));
	extension.add(Php::Constant("APPLICATION_ENV", "production"));
	
	extension.add(Php::Constant(PHP_NAMESPACE "_COMPILE_TIME", __DATE__ " " __TIME__));
	
	
	//	This function returns the path name for a given PHP object.
	//	PHP code:
	// 	spl_autoload_register(function($class){
	// 		if ( $file = PHP_NAMESPACE\get_autoload_file($class) ) {
	// //		echo $class, "<br>\n";
	// 			include $file;
	// 		}
	// 	});
	extension.add( PHP_NAMESPACE "\\get_autoload_file", Autoload::getFile, {
		Php::ByVal("className", Php::Type::String, true)
	} );
	

	// Tell the PHP engine that the php.ini variables "project.var1"
	// and "project.var2", etc. are usable.
	// These names must be compiled in to the extension before their
	// values can be updated from php.ini.
	extension.add(Php::Ini(EXTENSION_NAME ".var1", 11));
	extension.add(Php::Ini(EXTENSION_NAME ".var2", "a string"));
	extension.add(Php::Ini(EXTENSION_NAME ".var3", 1.1));


	// return the extension
	return extension;
}


}	//	extern C
