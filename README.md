# FPU

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
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);  

### FDiv
module fdiv(  
    input wire [31:0] s,  
    input wire [31:0] t,  
    output wire [31:0] d,  
    output wire overflow,  // not yet  
    output wire underflow  // not yet  
);
