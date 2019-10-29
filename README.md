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
- fadd, fmul, finv, fsqrtを作成した

### TODO:
- 仕様を満たす範囲内で処理を簡略化する
- 必要ならば他のモジュールも作成する