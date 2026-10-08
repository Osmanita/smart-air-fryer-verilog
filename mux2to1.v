
module mux2to1 #(parameter WIDTH = 4)
               (in0, in1, sel, out);

    input  [WIDTH-1:0] in0, in1;
    input              sel;
    output [WIDTH-1:0] out;
    reg    [WIDTH-1:0] out;

    always @(in0 or in1 or sel)// sel = 0 -> in0, sel = 1 -> in1
        case (sel)
            1'b0: out = in0;
            1'b1: out = in1;
        endcase

endmodule