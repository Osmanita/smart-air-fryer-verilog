
module mux_4to1 #(parameter WIDTH = 4)
                (in0, in1, in2, in3, sel, out);
    input  [WIDTH-1:0] in0, in1, in2, in3;
    input  [1:0]       sel;
    output [WIDTH-1:0] out;
    reg    [WIDTH-1:0] out;

    always @(in0 or in1 or in2 or in3 or sel)
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
        endcase
endmodule