/**
	Wrap Murmurhash3 with an object.
*/

#ifndef DISKERROR_HASH_H
#define DISKERROR_HASH_H
#pragma once

struct Hash
{

	size_t operator()(const std::string&) const;
	
};

#endif	//	DISKERROR_HASH_H
