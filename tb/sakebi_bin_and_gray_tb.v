module sakebi_bin_and_gray;

  reg  [3:0] r_i_bin;
  wire [3:0] w_gray;
  wire [3:0] w_o_bin;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, sakebi_bin_and_gray);
  end

  sakebi_bin2gray bin2gray(
    .i_bin  (r_i_bin),
    .o_gray (w_gray )
  );

  sakebi_gray2bin gray2bin(
    .i_gray (w_gray ),
    .o_bin  (w_o_bin)
  );

  initial begin
    r_i_bin = 4'h0;
    #1
    r_i_bin = 4'h1;
    #1
    r_i_bin = 4'h2;
    #1
    r_i_bin = 4'h3;
    #1
    r_i_bin = 4'h4;
    #1
    r_i_bin = 4'h5;
    #1
    r_i_bin = 4'h6;
    #1
    r_i_bin = 4'h7;
    #1
    r_i_bin = 4'h8;
    #1
    r_i_bin = 4'h9;
    #1
    r_i_bin = 4'hA;
    #1
    r_i_bin = 4'hB;
    #1
    r_i_bin = 4'hC;
    #1
    r_i_bin = 4'hD;
    #1
    r_i_bin = 4'hE;
    #1
    r_i_bin = 4'hF;
    #1
    $finish;
  end

endmodule
