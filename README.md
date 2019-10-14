# FPU

### FAdd
module fadd(
    input wire [31:0] s,  // source
    input wire [31:0] t,  // source
    output wire [31:0] d,  // destination
    output wire overflow
);

### FMul
module fmul(
    input wire [31:0] s,  // source
    input wire [31:0] t,  // source
    output wire [31:0] d,  // destination
    output wire overflow,
    output wire underflow
);

### FDiv
module fdiv(
    input wire [31:0] s,  // source
    input wire [31:0] t,  // source
    output wire [31:0] d,  // destination
    output wire overflow,
    output wire underflow
);
