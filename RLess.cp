/**
	Compare strings starting with the last charcters in the strings, then the first characters,
	then the 2nd to last characters, then the 2nd charcters, etc.
*/

#include "RLess.h"

using namespace std;

//	if A is less than B then return true, if equal or greater retrun false
bool RLess::operator()(const char* a, const char* b) const
{
	int aLen = strlen(a), bLen = strlen(b);
	
	//	If length of B is zero then A can't be less than B.
	if ( bLen == 0 ) {
		return false;
	}
	
	//	If we got here then the length of B is greater than zero.
	if ( aLen == 0 ) {
		return true;
	}
	
	const char* aBeg = const_cast<char*>(a - 1);
	const char* bBeg = const_cast<char*>(b - 1);
	const char* aEnd = const_cast<char*>(a + aLen);
	const char* bEnd = const_cast<char*>(b + bLen);
	
	while ( aBeg!=aEnd && bBeg!=bEnd ) {
		aEnd--; bEnd--;
		if (*aEnd < *bEnd) {
			return true;
		}
		
		if (*aEnd > *bEnd) {
			return false;
		}
		//	if equal then continue checking
		
		//	if B is finished then no matter what A is return false
		if ( bBeg==bEnd ) {
			return false;
		}
		
		aBeg++; bBeg++;
		if (*aBeg < *bBeg) {
			return true;
		}
		
		if (*aBeg > *bBeg) {
			return false;
		}
		//	if equal then continue checking
		
		//	if B is finished and no matter what A is, then return false
		if ( bBeg==bEnd ) {
			return false;
		}
	}
	
	//	If B still isn't finished then A must be the one that ended the 'while' loop and is therefore lesser.
	if ( bBeg<bEnd ) {
		return true;
	}
	
	//	either 'a==b' or A is longer than B
	return false;
}
