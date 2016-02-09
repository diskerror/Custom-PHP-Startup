/**
	Auto loader assistant.
	Returns the file name corrisponding to a class name.

*/

#ifndef DISKERROR_AUTOLOADVALUES_H
#define DISKERROR_AUTOLOADVALUES_H
#pragma once

#include "Hash.h"

class AutoloadValues
{
protected:

	static const std::unordered_map<std::string, const char *, Hash> _val;


public:
	
	static Php::Value get(Php::Parameters &);
	
};

#endif	//	DISKERROR_AUTOLOADVALUES_H
