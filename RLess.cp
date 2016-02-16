/**
	Compare strings starting with the tail.
*/

#include "RLess.h"

using namespace std;

//	if 'a' is less than 'b' then return true, if equal or greater retrun false
bool RLess::operator()(const char* a, const char* b) const
{
	const char* ap = (char*) a + strlen(a);
	const char* bp = (char*) b + strlen(b);
	
	while ( ap>a && bp>b ) {
		ap--; bp--;
		
		if (*ap < *bp)
			return true;
			
		if (*ap > *bp)
			return false;
		//	if equal then continue checking
	}
	
	//	If 'b' still isn't finished then 'a' must be the one the ended the 'while' loop and is therefore lesser.
	if ( bp>b ) {
		return true;
	}
	
	//	either 'a==b' or 'a' is longer than 'b'
	return false;
}
