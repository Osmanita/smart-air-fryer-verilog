// datapath_tb.v
// EEE 248 / CNG 232 - Logic Design - Project 2
// Testbench for the 4-bit Smart Air Fryer Datapath
// Eray Istanbul - 2585099
// Osman Caner Cakmak - 2584829

`timescale 1ns/1ps

module datapath_tb;

    parameter WIDTH = 4;

    reg              clk;
    reg              wrt_en;
    reg              toggle;
    reg              load_data;
    reg              input_sel;
    reg  [1:0]       wrt_addr;
    reg  [1:0]       rd_addr1;
    reg  [1:0]       rd_addr2;
    reg  [2:0]       ccu_opcode;
    reg  [WIDTH-1:0] User;
    reg  [WIDTH-1:0] Sensor;

    wire [WIDTH-1:0] Output;
    wire             L, E, G;

    integer count;

    // wrt_addr / decoder mapping:
    //   00 -> REG0 (Current Temp)
    //   01 -> REG2 (Target Time)   dec_out[2]
    //   10 -> REG3 (Target Temp)   dec_out[3]
    //   11 -> REG1 (Current Time)  dec_out[1]
    //
    // rd_addr / mux_4to1 mapping (in0=reg0,in1=reg1,in2=reg2,in3=reg3):
    //   00 -> REG0 (Current Temp)
    //   01 -> REG1 (Current Time)
    //   10 -> REG2 (Target Time)
    //   11 -> REG3 (Target Temp)
    //
    // input_sel: 0 -> Sensor, 1 -> User

    datapath #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .wrt_en    (wrt_en),
        .wrt_addr  (wrt_addr),
        .toggle    (toggle),
        .rd_addr1  (rd_addr1),
        .rd_addr2  (rd_addr2),
        .ccu_opcode(ccu_opcode),
        .input_sel (input_sel),
        .load_data (load_data),
        .Sensor    (Sensor),
        .User      (User),
        .Output    (Output),
        .L         (L),
        .E         (E),
        .G         (G)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        wrt_en     = 1'b0;
        toggle     = 1'b0;
        load_data  = 1'b0;
        input_sel  = 1'b0;
        wrt_addr   = 2'b00;
        rd_addr1   = 2'b00;
        rd_addr2   = 2'b00;
        ccu_opcode = 3'b000;
        User       = 4'd0;
        Sensor     = 4'd0;
        count      = 0;

        #20;

        // ===== PHASE 1: PREHEATING MODE =====
        // test case (a): Sensor < User (Current Temp 4 < Target Temp 14)

        $display("===== PHASE 1: PREHEATING MODE =====");
        $display("Test case (a): Sensor value is initially less than User value");

        // load Target Temp = 14 into REG3 (wrt_addr=10, input_sel=1 for User)
        $display("Loading Target Temp = 14 into target temperature register");
        User      = 4'd14;
        input_sel = 1'b1;
        load_data = 1'b0;
        wrt_addr  = 2'b10;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        // load Current Temp = 4 into REG0 (wrt_addr=00, input_sel=0 for Sensor)
        $display("Loading Current Temp = 4 into current temperature register");
        Sensor    = 4'd4;
        input_sel = 1'b0;
        load_data = 1'b0;
        wrt_addr  = 2'b00;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        // compare Current Temp (rd_addr1=00) vs Target Temp (rd_addr2=11)
        rd_addr1   = 2'b00;
        rd_addr2   = 2'b11;
        ccu_opcode = 3'b011;
        @(posedge clk); #1;

        count = 0;
        while (!E && count < 20) begin
            count = count + 1;

            if (L) begin
                $display("Preheat step %0d: Current Temp is lower than Target Temp. Incrementing by 2.", count);

                // increment Current Temp, result goes to data_out_q after one clock
                rd_addr1   = 2'b00;
                ccu_opcode = 3'b101;
                @(posedge clk); #1;
                // wait one more clock for data_out_q to latch the result
                @(posedge clk); #1;

                // write data_out_q back to REG0 via load_data=1
                load_data = 1'b1;
                wrt_addr  = 2'b00;
                wrt_en    = 1'b1;
                toggle    = 1'b1;
                ccu_opcode = 3'b000;
                @(posedge clk); #1;
                wrt_en    = 1'b0;
                toggle    = 1'b0;
                load_data = 1'b0;
                @(posedge clk); #1;
            end

            // compare again
            rd_addr1   = 2'b00;
            rd_addr2   = 2'b11;
            ccu_opcode = 3'b011;
            @(posedge clk); #1;
        end

        $display("Phase 1 complete: Current Temp reached Target Temp.");

        // ===== PHASE 2: TIMER MODE =====

        $display("===== PHASE 2: TIMER MODE =====");

        // load Target Time = 5 into REG2 (wrt_addr=01, input_sel=1 for User)
        $display("Loading Target Time = 5 into target time register");
        User      = 4'd5;
        input_sel = 1'b1;
        load_data = 1'b0;
        wrt_addr  = 2'b01;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        // copy Target Time (rd_addr2=10->REG2) into Current Time (wrt_addr=11->REG1)
        $display("Copying Target Time into Current Time register");
        rd_addr2   = 2'b10;
        ccu_opcode = 3'b110;
        @(posedge clk); #1;
        @(posedge clk); #1;

        load_data = 1'b1;
        wrt_addr  = 2'b11;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        ccu_opcode = 3'b000;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        load_data = 1'b0;
        @(posedge clk); #1;

        // load 0 into REG2 (wrt_addr=01) to use as zero reference
        $display("Loading zero reference into target time register");
        User      = 4'd0;
        input_sel = 1'b1;
        load_data = 1'b0;
        wrt_addr  = 2'b01;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        // compare Current Time (rd_addr1=01->REG1) vs 0 (rd_addr2=10->REG2)
        rd_addr1   = 2'b01;
        rd_addr2   = 2'b10;
        ccu_opcode = 3'b011;
        @(posedge clk); #1;

        count = 0;
        while (!E && count < 20) begin
            count = count + 1;

            if (G) begin
                $display("Timer tick %0d: Current Time is greater than zero. Decrementing by 1.", count);

                // decrement Current Time
                rd_addr1   = 2'b01;
                ccu_opcode = 3'b001;
                @(posedge clk); #1;
                @(posedge clk); #1;

                // write back to REG1
                load_data = 1'b1;
                wrt_addr  = 2'b11;
                wrt_en    = 1'b1;
                toggle    = 1'b1;
                ccu_opcode = 3'b000;
                @(posedge clk); #1;
                wrt_en    = 1'b0;
                toggle    = 1'b0;
                load_data = 1'b0;
                @(posedge clk); #1;
            end

            // compare again
            rd_addr1   = 2'b01;
            rd_addr2   = 2'b10;
            ccu_opcode = 3'b011;
            @(posedge clk); #1;
        end

        $display("Phase 2 complete: Timer reached zero.");
        @(posedge clk); #1;
        $display("Final Output = %0d", Output);

        #50;

        // ===== TEST CASE (b): Sensor > User =====

        $display("===== TEST CASE (b): Sensor value is initially greater than User value =====");

        User      = 4'd3;
        input_sel = 1'b1;
        load_data = 1'b0;
        wrt_addr  = 2'b10;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        Sensor    = 4'd12;
        input_sel = 1'b0;
        load_data = 1'b0;
        wrt_addr  = 2'b00;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        rd_addr1   = 2'b00;
        rd_addr2   = 2'b11;
        ccu_opcode = 3'b011;
        @(posedge clk); #1;

        if (G)
            $display("Test case (b) successful: Current Temp (%0d) is greater than Target Temp (%0d). FLAG_G is high.", dut.reg0_q, dut.reg3_q);
        else
            $display("Test case (b) failed.");

        #20;

        // ===== TEST CASE (c): Sensor == User =====

        $display("===== TEST CASE (c): Sensor and User values are already equal =====");

        User      = 4'd8;
        input_sel = 1'b1;
        load_data = 1'b0;
        wrt_addr  = 2'b10;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        Sensor    = 4'd8;
        input_sel = 1'b0;
        load_data = 1'b0;
        wrt_addr  = 2'b00;
        wrt_en    = 1'b1;
        toggle    = 1'b1;
        @(posedge clk); #1;
        wrt_en    = 1'b0;
        toggle    = 1'b0;
        @(posedge clk); #1;

        rd_addr1   = 2'b00;
        rd_addr2   = 2'b11;
        ccu_opcode = 3'b011;
        @(posedge clk); #1;

        if (E)
            $display("Test case (c) successful: Current Temp equals Target Temp (%0d). FLAG_E is high.", dut.reg0_q);
        else
            $display("Test case (c) failed.");

        #20;
        $finish;
    end

endmodule
