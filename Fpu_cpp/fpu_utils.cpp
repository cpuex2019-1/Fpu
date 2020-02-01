#include <iostream>
#include <valarray>
using namespace std;

void print_int(unsigned int i) {
  cout << i << endl;
}

void print_binary(valarray<unsigned int> b) {
  for (int i=b.size()-1; i>=0; i--) {
    cout << b[i];
  }
  cout << endl;
}

uint64_t binary2int(valarray<unsigned int> b, int size) {
  uint64_t i = 0;
  for (int j=size-1; j>=0; j--) {
    i = (i << 1) + b[j];
  }
  return i;
}

valarray<unsigned int> int2binary(unsigned int i, int size) {
  valarray<unsigned int> b(size);
  for (int j=0; j<size; j++) {
    b[j] = i % 2;
    i = i >> 1;
  }
  return b;
}

void print_int_as_binary(int i, int size) {
  valarray<unsigned int> b = int2binary(i, size);
  print_binary(b);
}

void print_float_as_binary(float f, int size) {
  union {
    unsigned int i;
    float f;
  } data;
  data.f = f;
  valarray<unsigned int> b = int2binary(data.i, size);
  print_binary(b);
}

unsigned int logic_and(valarray<unsigned int> b) {
  for (int j=0; j<b.size(); j++) {
    if (b[j] == 0) { return 0; }
  }
  return 1;
}

unsigned int logic_or(valarray<unsigned int> b) {
  for (int j=0; j<b.size(); j++) {
    if (b[j] >= 1) { return 1; }
  }
  return 0;
}