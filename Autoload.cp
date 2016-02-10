/*
	Auto loader assistant.
	Returns the file name corrisponding to a class name.

*/

#include "Autoload.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////////////////////////
Php::Value Autoload::getFile(Php::Parameters &params)
{
	string className = params[0];
	
	auto search = _val.find(className);
	
	if ( search != _val.end() ) {
		return (Php::Value) search->second;
	}
	else {
		return "";
	}
}
