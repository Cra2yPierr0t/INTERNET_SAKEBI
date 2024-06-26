module sakebi_rmii_rx_tb;

  reg           r_rmii_REF_CLK  = 1'b0;
  reg           r_rmii_CRS_DV   = 1'b0;
  reg  [1:0]    r_rmii_RXD      = 2'b00;

  reg           r_axis_ACLK     = 1'b0;
  reg           r_axis_ARESETn  = 1'b1;
  wire          w_axis_TVALID;
  wire [7:0]    w_axis_TDATA;

  always #1 begin
    r_rmii_REF_CLK  <= ~r_rmii_REF_CLK;
  end

  always #4 begin
    r_axis_ACLK     <= ~r_axis_ACLK;
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, DUT);
  end

  sakebi_rmii_rx DUT(
    // RMII interfae
    .i_rmii_REF_CLK (r_rmii_REF_CLK ),
    .i_rmii_CRS_DV  (r_rmii_CRS_DV  ),
    .i_rmii_RXD     (r_rmii_RXD     ),
    // AXIS interface
    .i_axis_ACLK    (r_axis_ACLK    ),
    .i_axis_ARESETn (r_axis_ARESETn ),
    .o_axis_TVALID  (w_axis_TVALID  ),
    .o_axis_TDATA   (w_axis_TDATA   )
  );

  initial begin
    #10
    r_axis_ARESETn  = 1'b1;
    #10
    r_rmii_CRS_DV   = 1'b1;
    r_rmii_RXD      = 2'b00;
    #10
    r_rmii_RXD      = 2'b01;
    #20
    r_rmii_RXD      = 2'b11; // SFD
    #2
    r_rmii_RXD      = 2'b10;
    #8
    r_rmii_RXD      = 2'b11;
    #8
    r_rmii_RXD      = 2'b01;
    #8
    r_rmii_RXD      = 2'b10;
    #8
    r_rmii_RXD      = 2'b10;
    #8
    r_rmii_RXD      = 2'b11;
    #8
    r_rmii_RXD      = 2'b01;
    #8
    r_rmii_RXD      = 2'b10;
    #8
    r_rmii_RXD      = 2'b01;
    #8
    r_rmii_RXD      = 2'b11;
    #8
    r_rmii_RXD      = 2'b10;
    #8
    r_rmii_RXD      = 2'b10;
    #8
    r_rmii_RXD      = 2'b01;
    #8
    r_rmii_RXD      = 2'b11;
    r_rmii_CRS_DV   = 1'b0;
    #2
    r_rmii_RXD      = 2'b01;
    r_rmii_CRS_DV   = 1'b1;
    #2
    r_rmii_RXD      = 2'b10;
    r_rmii_CRS_DV   = 1'b0;
    #2
    r_rmii_RXD      = 2'b11;
    r_rmii_CRS_DV   = 1'b1;
    #2
    r_rmii_RXD      = 2'b00;
    r_rmii_CRS_DV   = 1'b0;
    #100
    $finish;
  end

endmodule
