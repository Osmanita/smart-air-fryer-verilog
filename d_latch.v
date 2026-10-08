
module d_latch (Q, D, enable);
    output Q;
    input  D, enable;
    reg    Q;

    always @(enable or D)
        if (enable) Q <= D;
endmodule