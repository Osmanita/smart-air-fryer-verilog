
module register_4bit #(parameter WIDTH = 4)
                     (Q, D, Clk, en);
    output [WIDTH-1:0] Q;
    input  [WIDTH-1:0] D;
    input              Clk, en;
    reg    [WIDTH-1:0] Q;

    always @(posedge Clk)
        if (en) Q <= D;
endmodule