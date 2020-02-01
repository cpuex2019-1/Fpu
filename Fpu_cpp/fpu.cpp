#include <iostream>
#include <cmath>
#include <valarray>
#include <random>
#include "fpu_utils.hpp"
using namespace std;

typedef valarray<unsigned int> wire;

wire floor(wire s) {
  wire exponent_s_wire(8), exponent_d_wire(8);
  wire mantissa_s_wire(23), mantissa_d_wire(23);
  wire one_mantissa_s_wire(24);
  bool sign_s, sign_d;
  unsigned int exponent_s, exponent_s_minus127, exponent_d;
  unsigned int mantissa_s, one_mantissa_s, mantissa_d;

  sign_s = s[31];
  exponent_s_wire = s[slice(23,8,1)];
  exponent_s = binary2int(exponent_s_wire, 8);
  exponent_s_minus127 = (exponent_s > 127) ? exponent_s - 127 : 0;
  mantissa_s_wire = s[slice(0,23,1)];
  mantissa_s = binary2int(mantissa_s_wire, 23);

  // cout << "src "; print_binary(s);
  // cout << "sign "; print_int(sign_s);
  // cout << "exponent "; print_binary(exponent_s_wire);
  // cout << "mantissa "; print_binary(mantissa_s_wire);
  // cout << "exponent-127 "; print_int(exponent_s_minus127);

  wire decimal_part_wire(23), integer_part_wire(23), integer_part_plusone_wire(23);
  unsigned int integer_part, integer_part_plusone;
  unsigned int flag, carry;
  // NOTE: shift(a) = shift right a
  decimal_part_wire = mantissa_s_wire.shift(- exponent_s_minus127);
  flag = logic_or(decimal_part_wire) && sign_s;
  integer_part_wire = mantissa_s_wire.shift(23 - exponent_s_minus127);
  integer_part = binary2int(integer_part_wire, 23);
  integer_part_plusone = integer_part + flag;
  integer_part_plusone_wire = int2binary(integer_part_plusone, 23);

  // cout << "flag "; print_int(flag);
  // cout << "decimal "; print_binary(decimal_part_wire);
  // cout << "integer "; print_binary(integer_part_wire);
  // cout << "logic_or(decimal) "; print_int(logic_or(decimal_part_wire));

  // print_int(integer_part_plusone);

  sign_d = sign_s;

  // TODO: to be cared
  mantissa_d = (integer_part_plusone << (23 - exponent_s_minus127)) % (1 << 23);

  carry = sign_s && (mantissa_s != 0) && (mantissa_d == 0);

  // cout << "integer_part_plusone " << integer_part_plusone << endl;
  // cout << "mantissa_d " << mantissa_d << endl;
  // cout << "exponent_s_minus127 " << exponent_s_minus127 << endl;
  // cout << "23 - exponent_s_minus127 " << 23 - exponent_s_minus127 << endl;
  // cout << "carry " << carry << endl;

  exponent_d = exponent_s + carry;
  exponent_d_wire = int2binary(exponent_d, 8);
  mantissa_d_wire = int2binary(mantissa_d, 23);

  valarray<unsigned int> d(32);
  valarray<unsigned int> dd(32);
  dd[31] = sign_d;
  dd[slice(23,8,1)] = exponent_d_wire;
  dd[slice(0,23,1)] = mantissa_d_wire;
  unsigned int d_is_s, d_is_zero, d_is_minuszero, d_is_minusone;
  d_is_s = exponent_s_minus127 >= 24;
  d_is_zero = (exponent_s <= 126) && !sign_s;
  d_is_minuszero = (exponent_s == 0) && sign_s;
  d_is_minusone = (exponent_s <= 126) && sign_s;

  // cout << "d_is_zero "; print_int(d_is_zero);
  // cout << "d_is_minuszero "; print_int(d_is_minuszero);
  // cout << "d_is_minusone "; print_int(d_is_minusone);

  d = d_is_s ? s :
  d_is_zero ? int2binary(0b0, 32) :
  d_is_minuszero ? int2binary(0b10000000000000000000000000000000, 32) :
  d_is_minusone ? int2binary(0b10111111100000000000000000000000, 32) :
  dd;

  // cout << "s "; print_binary(s);
  // cout << "d "; print_binary(d);


  // cout << endl;

  return d;
}

float floor_wrapper(float s) {
  union {
    unsigned int i;
    float f;
  } data;
  valarray<unsigned int> src(32), dest(32);
  float d;
  data.f = s;
  // cout << " src ";
  src = int2binary(data.i, 32);
  // for (int k=31; k>=0; k--) {
  //   cout << src[k];
  // }
  // cout << endl;

  dest = floor(src);

  // cout << "dest ";
  // for (int k=31; k>=0; k--) {
  //   cout << dest[k];
  // }
  // cout << endl;
  data.i = binary2int(dest, 32);
  d = data.f;
  return d;
}


#include <iostream>
#include <cmath>
#include <valarray>
#include <random>
#include "fpu_utils.hpp"
using namespace std;

typedef valarray<unsigned int> wire;

wire finv(wire s) {
  wire exponent_s_wire(8), exponent_d_wire(8);
  wire mantissa_s_wire(23), mantissa_d_wire(23);
  wire one_mantissa_s_wire(24);
  unsigned int sign_s, sign_d;
  unsigned int exponent_s, exponent_s_minus127, exponent_d;
  unsigned int mantissa_s, one_mantissa_s, mantissa_d;

  sign_s = s[31];
  exponent_s_wire = s[slice(23,8,1)];
  exponent_s = binary2int(exponent_s_wire, 8);
  exponent_s_minus127 = exponent_s > 127 ? exponent_s - 127 : 0;
  mantissa_s_wire = s[slice(0,23,1)];
  mantissa_s = binary2int(mantissa_s_wire, 23);

  one_mantissa_s_wire[23] = 1;
  one_mantissa_s_wire[slice(0,23,1)] = mantissa_s_wire;
  one_mantissa_s = binary2int(one_mantissa_s_wire, 24);

  // cout << "one_mantissa_s: "; print_int(one_mantissa_s);

  unsigned int target;
  wire target_wire(64);
  target_wire[slice(8,24,1)] = one_mantissa_s_wire;
  target = binary2int(target_wire, 64);

  // cout << "target_wire: "; print_binary(target_wire);
  // cout << "target: "; print_int(target);
  
  unsigned long x0, x1, x2;
  unsigned long a1, a2;
  unsigned long b1, b2;
  unsigned long c1, c2;
  unsigned int upper8, lower15;
  wire upper8_wire(8), lower15_wire(15);
  wire x0_wire(64), x1_wire(64), x2_wire(64);

  lower15 = 0;
  lower15_wire = int2binary(lower15, 15);
  upper8 =
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000000 ? 0b11111111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000001 ? 0b11111110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000010 ? 0b11111100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000011 ? 0b11111010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000100 ? 0b11111000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000101 ? 0b11110110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000110 ? 0b11110100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00000111 ? 0b11110010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001000 ? 0b11110000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001001 ? 0b11101110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001010 ? 0b11101100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001011 ? 0b11101010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001100 ? 0b11101001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001101 ? 0b11100111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001110 ? 0b11100101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00001111 ? 0b11100011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010000 ? 0b11100001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010001 ? 0b11100000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010010 ? 0b11011110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010011 ? 0b11011100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010100 ? 0b11011010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010101 ? 0b11011001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010110 ? 0b11010111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00010111 ? 0b11010101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011000 ? 0b11010100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011001 ? 0b11010010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011010 ? 0b11010000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011011 ? 0b11001111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011100 ? 0b11001101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011101 ? 0b11001011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011110 ? 0b11001010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00011111 ? 0b11001000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100000 ? 0b11000111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100001 ? 0b11000101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100010 ? 0b11000011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100011 ? 0b11000010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100100 ? 0b11000000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100101 ? 0b10111111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100110 ? 0b10111101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00100111 ? 0b10111100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101000 ? 0b10111010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101001 ? 0b10111001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101010 ? 0b10110111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101011 ? 0b10110110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101100 ? 0b10110100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101101 ? 0b10110011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101110 ? 0b10110010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00101111 ? 0b10110000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110000 ? 0b10101111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110001 ? 0b10101101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110010 ? 0b10101100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110011 ? 0b10101010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110100 ? 0b10101001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110101 ? 0b10101000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110110 ? 0b10100110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00110111 ? 0b10100101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111000 ? 0b10100100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111001 ? 0b10100010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111010 ? 0b10100001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111011 ? 0b10100000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111100 ? 0b10011110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111101 ? 0b10011101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111110 ? 0b10011100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b00111111 ? 0b10011010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000000 ? 0b10011001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000001 ? 0b10011000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000010 ? 0b10010111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000011 ? 0b10010101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000100 ? 0b10010100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000101 ? 0b10010011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000110 ? 0b10010010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01000111 ? 0b10010000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001000 ? 0b10001111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001001 ? 0b10001110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001010 ? 0b10001101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001011 ? 0b10001011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001100 ? 0b10001010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001101 ? 0b10001001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001110 ? 0b10001000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01001111 ? 0b10000111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010000 ? 0b10000110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010001 ? 0b10000100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010010 ? 0b10000011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010011 ? 0b10000010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010100 ? 0b10000001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010101 ? 0b10000000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010110 ? 0b01111111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01010111 ? 0b01111110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011000 ? 0b01111101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011001 ? 0b01111011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011010 ? 0b01111010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011011 ? 0b01111001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011100 ? 0b01111000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011101 ? 0b01110111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011110 ? 0b01110110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01011111 ? 0b01110101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100000 ? 0b01110100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100001 ? 0b01110011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100010 ? 0b01110010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100011 ? 0b01110001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100100 ? 0b01110000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100101 ? 0b01101111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100110 ? 0b01101110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01100111 ? 0b01101101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101000 ? 0b01101100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101001 ? 0b01101011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101010 ? 0b01101010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101011 ? 0b01101001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101100 ? 0b01101000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101101 ? 0b01100111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101110 ? 0b01100110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01101111 ? 0b01100101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110000 ? 0b01100100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110001 ? 0b01100011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110010 ? 0b01100010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110011 ? 0b01100001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110100 ? 0b01100000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110101 ? 0b01011111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110110 ? 0b01011110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01110111 ? 0b01011101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111000 ? 0b01011100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111001 ? 0b01011011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111010 ? 0b01011010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111011 ? 0b01011001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111100 ? 0b01011000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111101 ? 0b01011000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111110 ? 0b01010111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b01111111 ? 0b01010110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000000 ? 0b01010101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000001 ? 0b01010100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000010 ? 0b01010011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000011 ? 0b01010010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000100 ? 0b01010001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000101 ? 0b01010000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000110 ? 0b01010000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10000111 ? 0b01001111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001000 ? 0b01001110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001001 ? 0b01001101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001010 ? 0b01001100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001011 ? 0b01001011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001100 ? 0b01001010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001101 ? 0b01001010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001110 ? 0b01001001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10001111 ? 0b01001000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010000 ? 0b01000111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010001 ? 0b01000110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010010 ? 0b01000110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010011 ? 0b01000101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010100 ? 0b01000100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010101 ? 0b01000011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010110 ? 0b01000010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10010111 ? 0b01000010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011000 ? 0b01000001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011001 ? 0b01000000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011010 ? 0b00111111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011011 ? 0b00111110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011100 ? 0b00111110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011101 ? 0b00111101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011110 ? 0b00111100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10011111 ? 0b00111011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100000 ? 0b00111011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100001 ? 0b00111010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100010 ? 0b00111001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100011 ? 0b00111000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100100 ? 0b00111000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100101 ? 0b00110111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100110 ? 0b00110110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10100111 ? 0b00110101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101000 ? 0b00110101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101001 ? 0b00110100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101010 ? 0b00110011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101011 ? 0b00110010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101100 ? 0b00110010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101101 ? 0b00110001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101110 ? 0b00110000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10101111 ? 0b00110000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110000 ? 0b00101111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110001 ? 0b00101110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110010 ? 0b00101110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110011 ? 0b00101101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110100 ? 0b00101100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110101 ? 0b00101011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110110 ? 0b00101011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10110111 ? 0b00101010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111000 ? 0b00101001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111001 ? 0b00101001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111010 ? 0b00101000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111011 ? 0b00100111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111100 ? 0b00100111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111101 ? 0b00100110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111110 ? 0b00100101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b10111111 ? 0b00100101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000000 ? 0b00100100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000001 ? 0b00100011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000010 ? 0b00100011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000011 ? 0b00100010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000100 ? 0b00100001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000101 ? 0b00100001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000110 ? 0b00100000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11000111 ? 0b00100000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001000 ? 0b00011111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001001 ? 0b00011110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001010 ? 0b00011110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001011 ? 0b00011101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001100 ? 0b00011100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001101 ? 0b00011100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001110 ? 0b00011011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11001111 ? 0b00011011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010000 ? 0b00011010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010001 ? 0b00011001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010010 ? 0b00011001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010011 ? 0b00011000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010100 ? 0b00011000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010101 ? 0b00010111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010110 ? 0b00010110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11010111 ? 0b00010110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011000 ? 0b00010101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011001 ? 0b00010101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011010 ? 0b00010100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011011 ? 0b00010011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011100 ? 0b00010011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011101 ? 0b00010010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011110 ? 0b00010010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11011111 ? 0b00010001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100000 ? 0b00010001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100001 ? 0b00010000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100010 ? 0b00001111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100011 ? 0b00001111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100100 ? 0b00001110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100101 ? 0b00001110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100110 ? 0b00001101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11100111 ? 0b00001101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101000 ? 0b00001100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101001 ? 0b00001100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101010 ? 0b00001011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101011 ? 0b00001010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101100 ? 0b00001010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101101 ? 0b00001001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101110 ? 0b00001001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11101111 ? 0b00001000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110000 ? 0b00001000 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110001 ? 0b00000111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110010 ? 0b00000111 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110011 ? 0b00000110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110100 ? 0b00000110 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110101 ? 0b00000101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110110 ? 0b00000101 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11110111 ? 0b00000100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111000 ? 0b00000100 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111001 ? 0b00000011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111010 ? 0b00000011 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111011 ? 0b00000010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111100 ? 0b00000010 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111101 ? 0b00000001 :
  binary2int(mantissa_s_wire[slice(15,8,1)], 8) == 0b11111110 ? 0b00000001 : 00000000;
  upper8_wire = int2binary(upper8, 8);

  x0_wire[31] = 1;
  x0_wire[slice(23,8,1)] = upper8_wire;
  x0_wire[slice(8,15,1)] = lower15_wire;

  // cout << "initial "; print_binary(upper8_wire);
  // cout << "x0: "; print_binary(x0_wire);

  x0 = binary2int(x0_wire, 64);
  a1 = x0 << 1;
  b1 = (target * x0) >> 31;
  c1 = (b1 * x0) >> 32;
  x1 = a1 - c1;
  x1_wire = int2binary(x1, 64);

  // cout << "a1: "; print_int_as_binary(a1, 64);
  // cout << "b1: "; print_int_as_binary(b1, 64);
  // cout << "c1: "; print_int_as_binary(c1, 64);

  // cout << "x1: "; print_binary(x1_wire);

  a2 = x1 << 1;
  b2 = (target * x1) >> 31;
  c2 = (b2 * x1) >> 32;
  x2 = a2 - c2;
  x2_wire = int2binary(x2, 64);

  // cout << "a2: "; print_int_as_binary(a1, 64);
  // cout << "b2: "; print_int_as_binary(b1, 64);
  // cout << "c2: "; print_int_as_binary(c1, 64);

  // cout << "x2: "; print_binary(x2_wire);

  sign_d = sign_s;
  exponent_d =
    (exponent_s == 254) ? 0 :
    (mantissa_s == 0) ? 254 - exponent_s :
    253 - exponent_s;
  exponent_d_wire = int2binary(exponent_d, 8);

  unsigned int ulp, guard, round, sticky, flag;
  ulp = x2_wire[8];
  guard = x2_wire[7];
  round = x2_wire[6];
  sticky = logic_or(x2_wire[slice(0,6,1)]);
  flag = (ulp && guard && (~round) && (~sticky)) || (guard && (~round) && sticky) || (guard && round);

  // cout << binary2int(x2_wire[slice(8,23,1)], 23) + flag << endl;

  mantissa_d_wire =
    (exponent_s == 253) ? x2_wire[slice(9,23,1)] :
    (exponent_s == 254) ? x2_wire[slice(8,23,1)] :
    (mantissa_s == 0) ? mantissa_s_wire :
    int2binary((binary2int(x2_wire[slice(8,23,1)], 23) + flag), 23);

  mantissa_d = binary2int(mantissa_d_wire, 23);

  unsigned int overflow, underflow;
  wire d(32);

  d[31] = sign_d;
  d[slice(23,8,1)] = exponent_d_wire;
  d[slice(0,23,1)] = mantissa_d_wire;
  overflow = 0;
  underflow = 0;

  return d;

}

float finv_wrapper(float s) {
  union {
    unsigned int i;
    float f;
  } data;
  valarray<unsigned int> src(32), dest(32);
  float d;
  data.f = s;
  // cout << " src ";
  src = int2binary(data.i, 32);
  // for (int k=31; k>=0; k--) {
  //   cout << src[k];
  // }
  // cout << endl;

  dest = finv(src);

  // cout << "dest ";
  // for (int k=31; k>=0; k--) {
  //   cout << dest[k];
  // }
  // cout << endl;
  data.i = binary2int(dest, 32);
  d = data.f;
  return d;
}

#include <iostream>
#include <cmath>
#include <valarray>
#include <random>
#include "fpu_utils.hpp"
using namespace std;

typedef valarray<unsigned int> wire;

wire fsqrt(wire s) {
  wire exponent_s_wire(8), exponent_d_wire(8);
  wire mantissa_s_wire(23), mantissa_d_wire(23);
  wire one_mantissa_s_wire(24);
  unsigned int sign_s, sign_d;
  unsigned int exponent_s, exponent_s_minus127, exponent_d;
  unsigned int mantissa_s, one_mantissa_s, mantissa_d;

  sign_s = s[31];
  exponent_s_wire = s[slice(23,8,1)];
  exponent_s = binary2int(exponent_s_wire, 8);
  mantissa_s_wire = s[slice(0,23,1)];
  mantissa_s = binary2int(mantissa_s_wire, 23);

  one_mantissa_s_wire[23] = 1;
  one_mantissa_s_wire[slice(0,23,1)] = mantissa_s_wire;
  one_mantissa_s = binary2int(one_mantissa_s_wire, 24);

  uint64_t target;
  wire target_wire(64);

  if (exponent_s_wire[0] == 0) {
    target_wire[slice(9,24,1)] = one_mantissa_s_wire;
  } else {
    target_wire[slice(8,24,1)] = one_mantissa_s_wire;
  }
  target = binary2int(target_wire, 64);

  uint64_t x0, x1, x2, y2;
  uint64_t a1, a2;
  uint64_t b1, b2;
  uint64_t c1, c2;
  uint64_t d1, d2;
  uint64_t e1, e2;
  unsigned int upper7, lower16;
  wire upper7_wire(7), lower16_wire(16);
  wire x0_wire(64), x1_wire(64), x2_wire(64), y2_wire(64);

  lower16 = 0;
  lower16_wire = int2binary(lower16, 16);
  upper7 =
    exponent_s_wire[0] == 1 ? (
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000000 ? 0b1111111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000001 ? 0b1111111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000010 ? 0b1111111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000011 ? 0b1111110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000100 ? 0b1111110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000101 ? 0b1111101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000110 ? 0b1111101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000111 ? 0b1111100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001000 ? 0b1111100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001001 ? 0b1111011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001010 ? 0b1111011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001011 ? 0b1111010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001100 ? 0b1111010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001101 ? 0b1111001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001110 ? 0b1111001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001111 ? 0b1111001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010000 ? 0b1111000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010001 ? 0b1111000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010010 ? 0b1110111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010011 ? 0b1110111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010100 ? 0b1110111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010101 ? 0b1110110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010110 ? 0b1110110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010111 ? 0b1110101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011000 ? 0b1110101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011001 ? 0b1110101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011010 ? 0b1110100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011011 ? 0b1110100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011100 ? 0b1110011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011101 ? 0b1110011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011110 ? 0b1110011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011111 ? 0b1110010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100000 ? 0b1110010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100001 ? 0b1110010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100010 ? 0b1110001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100011 ? 0b1110001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100100 ? 0b1110001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100101 ? 0b1110000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100110 ? 0b1110000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100111 ? 0b1110000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101000 ? 0b1101111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101001 ? 0b1101111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101010 ? 0b1101111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101011 ? 0b1101110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101100 ? 0b1101110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101101 ? 0b1101110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101110 ? 0b1101101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101111 ? 0b1101101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110000 ? 0b1101101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110001 ? 0b1101100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110010 ? 0b1101100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110011 ? 0b1101100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110100 ? 0b1101011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110101 ? 0b1101011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110110 ? 0b1101011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110111 ? 0b1101011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111000 ? 0b1101010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111001 ? 0b1101010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111010 ? 0b1101010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111011 ? 0b1101001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111100 ? 0b1101001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111101 ? 0b1101001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111110 ? 0b1101001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111111 ? 0b1101000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000000 ? 0b1101000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000001 ? 0b1101000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000010 ? 0b1100111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000011 ? 0b1100111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000100 ? 0b1100111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000101 ? 0b1100111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000110 ? 0b1100110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000111 ? 0b1100110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001000 ? 0b1100110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001001 ? 0b1100110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001010 ? 0b1100101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001011 ? 0b1100101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001100 ? 0b1100101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001101 ? 0b1100101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001110 ? 0b1100100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001111 ? 0b1100100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010000 ? 0b1100100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010001 ? 0b1100100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010010 ? 0b1100011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010011 ? 0b1100011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010100 ? 0b1100011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010101 ? 0b1100011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010110 ? 0b1100010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010111 ? 0b1100010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011000 ? 0b1100010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011001 ? 0b1100010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011010 ? 0b1100010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011011 ? 0b1100001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011100 ? 0b1100001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011101 ? 0b1100001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011110 ? 0b1100001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011111 ? 0b1100000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100000 ? 0b1100000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100001 ? 0b1100000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100010 ? 0b1100000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100011 ? 0b1100000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100100 ? 0b1011111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100101 ? 0b1011111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100110 ? 0b1011111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100111 ? 0b1011111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101000 ? 0b1011111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101001 ? 0b1011110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101010 ? 0b1011110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101011 ? 0b1011110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101100 ? 0b1011110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101101 ? 0b1011110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101110 ? 0b1011101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101111 ? 0b1011101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110000 ? 0b1011101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110001 ? 0b1011101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110010 ? 0b1011101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110011 ? 0b1011100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110100 ? 0b1011100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110101 ? 0b1011100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110110 ? 0b1011100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110111 ? 0b1011100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111000 ? 0b1011011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111001 ? 0b1011011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111010 ? 0b1011011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111011 ? 0b1011011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111100 ? 0b1011011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111101 ? 0b1011011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111110 ? 0b1011010 : 0b1011010
    ) : (
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000000 ? 0b1011010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000001 ? 0b1011010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000010 ? 0b1011001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000011 ? 0b1011001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000100 ? 0b1011001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000101 ? 0b1011000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000110 ? 0b1011000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0000111 ? 0b1011000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001000 ? 0b1010111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001001 ? 0b1010111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001010 ? 0b1010111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001011 ? 0b1010110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001100 ? 0b1010110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001101 ? 0b1010110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001110 ? 0b1010101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0001111 ? 0b1010101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010000 ? 0b1010101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010001 ? 0b1010101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010010 ? 0b1010100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010011 ? 0b1010100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010100 ? 0b1010100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010101 ? 0b1010011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010110 ? 0b1010011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0010111 ? 0b1010011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011000 ? 0b1010011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011001 ? 0b1010010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011010 ? 0b1010010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011011 ? 0b1010010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011100 ? 0b1010001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011101 ? 0b1010001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011110 ? 0b1010001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0011111 ? 0b1010001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100000 ? 0b1010000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100001 ? 0b1010000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100010 ? 0b1010000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100011 ? 0b1010000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100100 ? 0b1001111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100101 ? 0b1001111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100110 ? 0b1001111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0100111 ? 0b1001111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101000 ? 0b1001111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101001 ? 0b1001110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101010 ? 0b1001110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101011 ? 0b1001110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101100 ? 0b1001110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101101 ? 0b1001101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101110 ? 0b1001101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0101111 ? 0b1001101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110000 ? 0b1001101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110001 ? 0b1001100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110010 ? 0b1001100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110011 ? 0b1001100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110100 ? 0b1001100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110101 ? 0b1001100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110110 ? 0b1001011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0110111 ? 0b1001011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111000 ? 0b1001011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111001 ? 0b1001011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111010 ? 0b1001011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111011 ? 0b1001010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111100 ? 0b1001010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111101 ? 0b1001010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111110 ? 0b1001010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b0111111 ? 0b1001010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000000 ? 0b1001001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000001 ? 0b1001001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000010 ? 0b1001001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000011 ? 0b1001001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000100 ? 0b1001001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000101 ? 0b1001000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000110 ? 0b1001000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1000111 ? 0b1001000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001000 ? 0b1001000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001001 ? 0b1001000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001010 ? 0b1001000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001011 ? 0b1000111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001100 ? 0b1000111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001101 ? 0b1000111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001110 ? 0b1000111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1001111 ? 0b1000111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010000 ? 0b1000111 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010001 ? 0b1000110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010010 ? 0b1000110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010011 ? 0b1000110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010100 ? 0b1000110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010101 ? 0b1000110 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010110 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1010111 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011000 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011001 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011010 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011011 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011100 ? 0b1000101 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011101 ? 0b1000100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011110 ? 0b1000100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1011111 ? 0b1000100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100000 ? 0b1000100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100001 ? 0b1000100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100010 ? 0b1000100 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100011 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100100 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100101 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100110 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1100111 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101000 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101001 ? 0b1000011 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101010 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101011 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101100 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101101 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101110 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1101111 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110000 ? 0b1000010 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110001 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110010 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110011 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110100 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110101 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110110 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1110111 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111000 ? 0b1000001 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111001 ? 0b1000000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111010 ? 0b1000000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111011 ? 0b1000000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111100 ? 0b1000000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111101 ? 0b1000000 :
    binary2int(mantissa_s_wire[slice(16,7,1)], 7) == 0b1111110 ? 0b1000000 : 0b1000000
    );
  upper7_wire = int2binary(upper7, 7);

  x0_wire[slice(24,7,1)] = upper7_wire;
  x0_wire[slice(8,16,1)] = lower16_wire;
  x0 = binary2int(x0_wire, 64);

  a1 = x0 >> 1;
  b1 = a1 + x0;
  c1 = (target * x0) >> 31;
  d1 = (x0 * x0) >> 31;
  e1 = (c1 * d1) >> 32;
  x1 = b1 - e1;

  a2 = x1 >> 1;
  b2 = a2 + x1;
  c2 = (target * x1) >> 31;
  d2 = (x1 * x1) >> 31;
  e2 = (c2 * d2) >> 32;
  x2 = b2 - e2;

  y2 = (x2 * target) >> 31;
  y2_wire = int2binary(y2, 64);

  unsigned int tmp1, tmp2, tmp3;
  sign_d = 0;

  tmp1 = exponent_s - 127;
  tmp2 = tmp1 >> 1;
  tmp3 = tmp2 + 127;
  exponent_d = tmp3 % 256;
  exponent_d_wire = int2binary(exponent_d, 8);

  unsigned int ulp, guard, round, sticky, flag;
  ulp = y2_wire[8];
  guard = y2_wire[7];
  round = y2_wire[6];
  sticky = logic_or(y2_wire[slice(0,6,1)]);
  flag = (ulp && guard && (~round) && (~sticky)) || (guard && (~round) && sticky) || (guard && round);
  mantissa_d = binary2int(y2_wire[slice(8,23,1)], 23) + flag;
  mantissa_d_wire = int2binary(mantissa_d, 23);

  wire d(32);
  d[31] = sign_d;
  d[slice(23,8,1)] = exponent_d_wire;
  d[slice(0,23,1)] = mantissa_d_wire;

  return d;
}

float fsqrt_wrapper(float s) {
  union {
    unsigned int i;
    float f;
  } data;
  valarray<unsigned int> src(32), dest(32);
  float d;
  data.f = s;
  // cout << " src ";
  src = int2binary(data.i, 32);
  // for (int k=31; k>=0; k--) {
  //   cout << src[k];
  // }
  // cout << endl;

  dest = fsqrt(src);

  // cout << "dest ";
  // for (int k=31; k>=0; k--) {
  //   cout << dest[k];
  // }
  // cout << endl;
  data.i = binary2int(dest, 32);
  d = data.f;
  return d;
}
