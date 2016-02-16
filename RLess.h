/**
	Compare strings starting with the tail.
*/

#ifndef DISKERROR_RLESS_H
#define DISKERROR_RLESS_H
#pragma once

struct RLess
{

	bool operator()(const char* a, const char* b) const;
	
};

#endif	//	DISKERROR_RLESS_H
