#include <iostream>
#include <valarray>
using namespace std;

void print_int(unsigned int i);
void print_binary(valarray<unsigned int> b);
uint64_t binary2int(valarray<unsigned int> b, int size);
valarray<unsigned int> int2binary(unsigned int i, int size);
void print_int_as_binary(int i, int size);
void print_float_as_binary(float f, int size);
unsigned int logic_and(valarray<unsigned int> b);
unsigned int logic_or(valarray<unsigned int> b);