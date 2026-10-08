module decoder (data_in, data_out);

   
    parameter ADDR_WIDTH = 2;     
    parameter OUT_WIDTH  = 4;     

    input  [ADDR_WIDTH-1:0] data_in;   
    output [OUT_WIDTH-1:0]  data_out;   
    reg    [OUT_WIDTH-1:0]  data_out;

  
    always @(data_in)
        case (data_in)
            2'b00:   data_out = 4'b0001;   // REG 0 - Current Temp
            2'b01:   data_out = 4'b0100;   // REG 2 - Target Time
            2'b10:   data_out = 4'b1000;   // REG 3 - Target Temp
            2'b11:   data_out = 4'b0010;   // REG 1 - Current Time
            default: data_out = 4'b0000;
        endcase

endmodule