/**
	Auto loader assistant.
	Returns the file name corrisponding to a class name.

*/

#ifndef DISKERROR_AUTOLOAD_H
#define DISKERROR_AUTOLOAD_H
#pragma once

#include "Hash.h"

class Autoload
{
protected:

	static const std::unordered_map<std::string, const char *, Hash> _val;


public:
	
	static Php::Value getFile(Php::Parameters &);
	
};

#endif	//	DISKERROR_AUTOLOAD_H
