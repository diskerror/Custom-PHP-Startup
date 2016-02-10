
#include "Autoload.h"

using namespace std;

void autoload(Php::Parameters &parameters)
{
	Php::Value f = Autoload::get(parameters);
	if ( f != "" ) {
		Php::call("include", f);
	}
}

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
	
	//	These work the same as PHP: define('PROJECT_PATH', '/var/www/EXTENSION_NAME');
// 	extension.add(Php::Constant("PROJECT_PATH", "/var/www/EXTENSION_NAME"));
// 	extension.add(Php::Constant("APPLICATION_PATH", "/var/www/EXTENSION_NAME/application"));
	
	extension.add( EXTENSION_NAME "\\get_autoload_file", Autoload::getFile, {
		Php::ByVal("className", Php::Type::String, true)
	} );
	
	//	PHP: spl_register_autoload('project\\autoload');
	extension.add( EXTENSION_NAME "\\autoload", autoload, {
		Php::ByVal("className", Php::Type::String, true)
	} );
	
	
	// return the extension
	return extension;
}


}	//	extern C
