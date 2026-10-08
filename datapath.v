module datapath #(parameter WIDTH = 4)
                (clk,
                 wrt_en, wrt_addr, toggle,
                 rd_addr1, rd_addr2,
                 ccu_opcode,
                 input_sel, load_data,
                 Sensor, User,
                 Output, L, E, G);

    // Inputs 
    input              clk;
    input              wrt_en;          
    input  [1:0]       wrt_addr;      
    input              toggle;          
    input  [1:0]       rd_addr1;       
    input  [1:0]       rd_addr2;       
    input  [2:0]       ccu_opcode;     
    input              input_sel;      
    input              load_data;      
    input  [WIDTH-1:0] Sensor;         
    input  [WIDTH-1:0] User;           

    // Outputs
    output [WIDTH-1:0] Output;          // Final output 
    output             L, E, G;        

    //Internal wires
    wire [3:0]         dec_out;        
    wire [3:0]         reg_we;         
    wire [WIDTH-1:0]   ext_data;       
    wire [WIDTH-1:0]   data_in;       
    wire [WIDTH-1:0]   reg0_q;         
    wire [WIDTH-1:0]   reg1_q;         
    wire [WIDTH-1:0]   reg2_q;         
    wire [WIDTH-1:0]   reg3_q;          
    wire [WIDTH-1:0]   mux1_out;       
    wire [WIDTH-1:0]   mux2_out;       
    wire [WIDTH-1:0]   ccu_result;     
    wire [WIDTH-1:0]   data_out_q;      
    wire               flag_L, flag_E, flag_G;

    // 2-to-4 Decoder 
    decoder DEC (//generates 4-bit one-hot signal out of 2 bit wrt_addr
        .data_in(wrt_addr),
        .data_out(dec_out)
    );

    // 3-input AND gates  one for each register, reg_we[i] decides which register to write
    and_gate A0 (.data_in1(dec_out[0]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[0]));
    and_gate A1 (.data_in1(dec_out[1]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[1]));
    and_gate A2 (.data_in1(dec_out[2]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[2]));
    and_gate A3 (.data_in1(dec_out[3]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[3]));

    mux2to1 #(.WIDTH(WIDTH)) MUX_SU (//Choose between sensor or user, decide on ext_data depending on input_sel
        .in0(Sensor), .in1(User), .sel(input_sel), .out(ext_data)
    );|

    mux2to1 #(.WIDTH(WIDTH)) MUX_LD (//Decides the value of registers' D input. Either ext_data or CCU final output, depending on load_data
        .in0(ext_data), .in1(data_out_q), .sel(load_data), .out(data_in)
    );

    //4 x 4-bit Registers
    register_4bit #(.WIDTH(WIDTH)) REG0 (//Current Temp, only written if reg_we[0] == 1
        .Q(reg0_q), .D(data_in), .Clk(clk), .en(reg_we[0])
    );
    register_4bit #(.WIDTH(WIDTH)) REG1 (//Target Time, o nly written if reg_we[1] == 1
        .Q(reg1_q), .D(data_in), .Clk(clk), .en(reg_we[1])
    );
    register_4bit #(.WIDTH(WIDTH)) REG2 (//Target Temp,  only written if reg_we[2] == 1
        .Q(reg2_q), .D(data_in), .Clk(clk), .en(reg_we[2])
    );
    register_4bit #(.WIDTH(WIDTH)) REG3 (//Current Time, only written if reg_we[3] == 1
        .Q(reg3_q), .D(data_in), .Clk(clk), .en(reg_we[3])
    );

    // 4-to-1 MUX (CCU input1)
    mux_4to1 #(.WIDTH(WIDTH)) MUX_R1 (
        .in0(reg0_q), .in1(reg1_q), .in2(reg2_q), .in3(reg3_q),
        .sel(rd_addr1), .out(mux1_out)
    );

    // 4-to-1 MUX (CCU input2)
    mux_4to1 #(.WIDTH(WIDTH)) MUX_R2 (
        .in0(reg0_q), .in1(reg1_q), .in2(reg2_q), .in3(reg3_q),
        .sel(rd_addr2), .out(mux2_out)
    );
    //Central Control Unit
    ccu #(.WIDTH(WIDTH)) CCU_INST (
        .input1(mux1_out), .input2(mux2_out),
        .op_code(ccu_opcode),//operates according to opcode
        .out(ccu_result),
        .flag_L(flag_L), .flag_E(flag_E), .flag_G(flag_G)//update flags (comparison result)
    );
    //Output Register, writes the final value of CCU to data_out_q at every clock edge
    register_4bit #(.WIDTH(WIDTH)) DATA_OUT (
        .Q(data_out_q), .D(ccu_result), .Clk(clk), .en(1'b1)
    );
    //Connecting wires to ports{module datapath #(parameter WIDTH = 4)
                (clk,
                 wrt_en, wrt_addr, toggle,
                 rd_addr1, rd_addr2,
                 ccu_opcode,
                 input_sel, load_data,
                 Sensor, User,
                 Output, L, E, G);

    // Inputs 
    input              clk;
    input              wrt_en;          
    input  [1:0]       wrt_addr;      
    input              toggle;          
    input  [1:0]       rd_addr1;       
    input  [1:0]       rd_addr2;       
    input  [2:0]       ccu_opcode;     
    input              input_sel;      
    input              load_data;      
    input  [WIDTH-1:0] Sensor;         
    input  [WIDTH-1:0] User;           

    // Outputs
    output [WIDTH-1:0] Output;          // Final output 
    output             L, E, G;        

    //Internal wires
    wire [3:0]         dec_out;        
    wire [3:0]         reg_we;         
    wire [WIDTH-1:0]   ext_data;       
    wire [WIDTH-1:0]   data_in;       
    wire [WIDTH-1:0]   reg0_q;         
    wire [WIDTH-1:0]   reg1_q;         
    wire [WIDTH-1:0]   reg2_q;         
    wire [WIDTH-1:0]   reg3_q;          
    wire [WIDTH-1:0]   mux1_out;       
    wire [WIDTH-1:0]   mux2_out;       
    wire [WIDTH-1:0]   ccu_result;     
    wire [WIDTH-1:0]   data_out_q;      
    wire               flag_L, flag_E, flag_G;

    // 2-to-4 Decoder 
    decoder DEC (//generates 4-bit one-hot signal out of 2 bit wrt_addr
        .data_in(wrt_addr),
        .data_out(dec_out)
    );

    // 3-input AND gates  one for each register, reg_we[i] decides which register to write
    and_gate A0 (.data_in1(dec_out[0]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[0]));
    and_gate A1 (.data_in1(dec_out[1]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[1]));
    and_gate A2 (.data_in1(dec_out[2]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[2]));
    and_gate A3 (.data_in1(dec_out[3]), .data_in2(toggle), .data_in3(wrt_en), .data_out(reg_we[3]));

    mux2to1 #(.WIDTH(WIDTH)) MUX_SU (//Choose between sensor or user, decide on ext_data depending on input_sel
        .in0(Sensor), .in1(User), .sel(input_sel), .out(ext_data)
    );|

    mux2to1 #(.WIDTH(WIDTH)) MUX_LD (//Decides the value of registers' D input. Either ext_data or CCU final output, depending on load_data
        .in0(ext_data), .in1(data_out_q), .sel(load_data), .out(data_in)
    );

    //4 x 4-bit Registers
    register_4bit #(.WIDTH(WIDTH)) REG0 (//Current Temp, only written if reg_we[0] == 1
        .Q(reg0_q), .D(data_in), .Clk(clk), .en(reg_we[0])
    );
    register_4bit #(.WIDTH(WIDTH)) REG1 (//Target Time, o nly written if reg_we[1] == 1
        .Q(reg1_q), .D(data_in), .Clk(clk), .en(reg_we[1])
    );
    register_4bit #(.WIDTH(WIDTH)) REG2 (//Target Temp,  only written if reg_we[2] == 1
        .Q(reg2_q), .D(data_in), .Clk(clk), .en(reg_we[2])
    );
    register_4bit #(.WIDTH(WIDTH)) REG3 (//Current Time, only written if reg_we[3] == 1
        .Q(reg3_q), .D(data_in), .Clk(clk), .en(reg_we[3])
    );

    // 4-to-1 MUX (CCU input1)
    mux_4to1 #(.WIDTH(WIDTH)) MUX_R1 (
        .in0(reg0_q), .in1(reg1_q), .in2(reg2_q), .in3(reg3_q),
        .sel(rd_addr1), .out(mux1_out)
    );

    // 4-to-1 MUX (CCU input2)
    mux_4to1 #(.WIDTH(WIDTH)) MUX_R2 (
        .in0(reg0_q), .in1(reg1_q), .in2(reg2_q), .in3(reg3_q),
        .sel(rd_addr2), .out(mux2_out)
    );
    //Central Control Unit
    ccu #(.WIDTH(WIDTH)) CCU_INST (
        .input1(mux1_out), .input2(mux2_out),
        .op_code(ccu_opcode),//operates according to opcode
        .out(ccu_result),
        .flag_L(flag_L), .flag_E(flag_E), .flag_G(flag_G)//update flags (comparison result)
    );
    //Output Register, writes the final value of CCU to data_out_q at every clock edge
    register_4bit #(.WIDTH(WIDTH)) DATA_OUT (
        .Q(data_out_q), .D(ccu_result), .Clk(clk), .en(1'b1)
    );
    //Connecting wires to ports
    assign Output = data_out_q;
    assign L = flag_L;
    assign E = flag_E;
    assign G = flag_G;

endmodule

}
    assign Output = data_out_q;
    assign L = flag_L;
    assign E = flag_E;
    assign G = flag_G;

endmodule
