/**
	Compare strings starting with the last charcters in the strings.
*/

#include "RLess.h"

using namespace std;

//	if A is less than B then return true, if equal or greater retrun false
bool RLess::operator()(const char* a, const char* b) const
{
	const char* aEnd = const_cast<char*>(a + strlen(a));
	const char* bEnd = const_cast<char*>(b + strlen(b));
	
	while ( a!=aEnd && b!=bEnd ) {
		aEnd--; bEnd--;
		if (*aEnd < *bEnd) {
			return true;
		}
		
		if (*aEnd > *bEnd) {
			return false;
		}
		
		//	if equal then continue checking
	}
	
	//	If B still isn't finished then A must be the one that ended the 'while' loop and is therefore lesser.
	if ( b<bEnd ) {
		return true;
	}
	
	//	either 'a==b' or A is longer than B
	return false;
}
