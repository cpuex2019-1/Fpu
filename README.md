# FPU

## インターフェース

### FAdd (fadd_second.sv)
module fadd(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow  
);

### FMul (fmul_second.sv)
module fmul(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);  

### FInv (finv_first.sv)
module fdiv(  
    input wire [31:0] s,  
    output wire [31:0] d,  
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);

## DONE:
- 演算器の大枠を作成した
    - 正規化数に対してはだいたい正しい値を返せる
    - FAddは非正規化数に対応した
    - FMulは一部の非正規化数の入力を除いてほぼ正しいモジュールができた

## TODO:
- 例外処理を行う
    - overflowやunderflowを正しく出力する
