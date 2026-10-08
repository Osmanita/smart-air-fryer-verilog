
module and_gate (data_in1, data_in2, data_in3, data_out);

    input  data_in1;
    input  data_in2;
    input  data_in3;
    output data_out;

    wire   w1;

    // Structural: built-in AND primitives
    and G1 (w1, data_in1, data_in2);
    and G2 (data_out, w1, data_in3);

endmodule