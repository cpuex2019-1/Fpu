# FPU

## インターフェース

### FAdd
module fadd(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow  
);

### FMul
module fmul(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow,  
    output wire underflow  
);  

### FInv
module finv(  
    input wire [31:0] s,  
    output wire [31:0] d,  
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);  

### FSqrt
module fsqrt(
    input wire [31:0] s,  
    output wire [31:0] d  
);  

## メモ

### DONE:
- 非正規化数処理を省いたFPUを作成した(fadd, fmul, floor, ftoi, itof, fneg, fabs, feq, flt)

### TODO:
- 非正規化数処理を省いたFPUを作成する(finv, fsqrt)
- 非正規化数を0と思って処理するようにする(できるだけ非自明な動作を避ける)
- finv, fsqrtなどを分割する
