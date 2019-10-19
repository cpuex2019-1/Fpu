# FPU

## インターフェース

### FAdd (fadd_first.sv)
module fadd(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow  
);

### FMul (fmul_first.sv)
module fmul(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);  

### FDiv (fdiv_first.sv)
module fdiv(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);

## DONE:
- 演算器の大枠を作成した
    - 正規化数に対してはだいたい正しい値を返せる

## TODO:
- 非正規化数に対応する
- 例外処理を行う
    - overflowやunderflowを正しく出力する
- 丸めを正しく行う
- 他の浮動小数点演算を実装する
    - feq, fneqなど
- クリティカルパスを分割する
