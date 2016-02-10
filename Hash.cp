/*
	Wrap hash function.
*/

#include "Hash.h"
#include "MurmurHash3.h"

using namespace std;

size_t Hash::operator()(const string& s) const
{
// 	uint32_t res;
// 	MurmurHash3_x86_32((const void *) s.c_str(), (const int) s.size(), 0, (void*) &res);
// 	return res;
	
	uint64_t res[2];
	MurmurHash3_x64_128((const void *) s.c_str(), (const int) s.size(), 0, (void*) &res);
	return res[0];
}
