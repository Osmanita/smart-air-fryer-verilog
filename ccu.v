module ccu #(parameter WIDTH = 4)
           (input1, input2, op_code, out, flag_L, flag_E, flag_G);
    input  [WIDTH-1:0] input1, input2;
    input  [2:0]       op_code;
    output [WIDTH-1:0] out;
    output             flag_L, flag_E, flag_G;

    reg    [WIDTH-1:0] out;
    reg                flag_L, flag_E, flag_G;

    always @(input1 or input2 or op_code) begin
        flag_L = 1'b0;
        flag_E = 1'b0;
        flag_G = 1'b0;

        case (op_code)
            3'b000: out = out;                  // noop
            3'b001: out = input1 - 1;           // decrement
            3'b010: out = input1;               // load (Data_in via input1)
            3'b011: begin                       // compare
                        out    = out;
                        flag_L = (input1 <  input2);
                        flag_E = (input1 == input2);
                        flag_G = (input1 >  input2);
                    end
            3'b100: out = input1;               // display R[xx]
            3'b101: out = input1 + 2;           // increment (+2)
            3'b110: out = input2;               // copy R[yy]->R[xx]
            3'b111: out = out;                  // store
            default: out = {WIDTH{1'b0}};
        endcase
    end
endmodule