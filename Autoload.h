/**
	Auto loader assistant.
	Returns the file name corrisponding to a class name.

*/

#ifndef DISKERROR_AUTOLOAD_H
#define DISKERROR_AUTOLOAD_H
#pragma once

#include "RLess.h"
typedef std::map<const char *, const char *, RLess> autoloadMap;

class Autoload
{
protected:

	static const autoloadMap _val;

public:
	static Php::Value getFile(Php::Parameters &);

};

#endif	//	DISKERROR_AUTOLOAD_H
