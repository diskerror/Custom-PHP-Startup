/*
	Auto loader assistant.
	Returns the file name corrisponding to a class name.

*/

#include "Autoload.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////////////////////////
Php::Value Autoload::getFile(Php::Parameters &params)
{
	const char* className = params[0];
	
	try {
		return _val.at(className);
	}
	catch (std::exception e) {
		return "";
	}
}

Php::Value Autoload::collisions()
{
	return (int32_t) (phpMembers - _val.size());
}
