
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
	static Php::Extension extension(EXTENSION_NAME, "0.1");
	
	//	These work the same as PHP: define('PROJECT_PATH', '/var/www/project');
	extension.add(Php::Constant("PROJECT_PATH", PROJECTPATH));
	extension.add(Php::Constant("APPLICATION_PATH", PROJECTPATH "/application"));
	extension.add(Php::Constant("APPLICATION_ENV", "production"));
	extension.add(Php::Constant("PHP_MEMBERS", Autoload::phpMembersStr));
	
	//	PHP code:
	// 	spl_autoload_register(function($class){
	// 		if ( $file = PHP_NAMESPACE\get_autoload_file($class) ) {
	// 			echo $class, "<br>\n";
	// 			include $file;
	// 		}
	// 	});
	extension.add( PHP_NAMESPACE "\\get_autoload_file", Autoload::getFile, {
		Php::ByVal("className", Php::Type::String, true)
	} );
	
	extension.add( PHP_NAMESPACE "\\collisions", Autoload::collisions );
	
	
	// return the extension
	return extension;
}


}	//	extern C
