/**
	Auto loader assistant.
	Returns the file name corrisponding to a class name.

*/

#ifndef DISKERROR_AUTOLOAD_H
#define DISKERROR_AUTOLOAD_H
#pragma once

#include "RLess.h"
typedef std::map<const char *, const char *, RLess> autoloadMap;

// #include "Hash.h"
// #include "REqual.h"
// typedef std::unordered_map<const char *, const char *, Hash, REqual> autoloadMap;

class Autoload
{
protected:

	static const autoloadMap _val;

public:
	static const size_t phpMembers;
	static const std::string phpMembersStr;
	
	static Php::Value getFile(Php::Parameters &);
	static Php::Value collisions();
};

#endif	//	DISKERROR_AUTOLOAD_H
