module sakebi_rmii_tx_tb;

  reg           r_rmii_REF_CLK  = 1'b0;
  wire          w_rmii_TX_EN;
  wire [1:0]    w_rmii_TXD;

  reg           r_axis_ACLK     = 1'b0;
  reg           r_axis_ARESETn  = 1'b1;
  reg           r_axis_TVALID;
  wire          w_axis_TREADY;
  reg  [7:0]    r_axis_TDATA;

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

  sakebi_rmii_tx DUT(
    // RMII interfae
    .i_rmii_REF_CLK (r_rmii_REF_CLK ),
    .o_rmii_TX_EN   (w_rmii_TX_EN   ),
    .o_rmii_TXD     (w_rmii_TXD     ),
    // AXIS interface
    .i_axis_ACLK    (r_axis_ACLK    ),
    .i_axis_ARESETn (r_axis_ARESETn ),
    .i_axis_TVALID  (r_axis_TVALID  ),
    .o_axis_TREADY  (w_axis_TREADY  ),
    .i_axis_TDATA   (r_axis_TDATA   )
  );

  initial begin
    #10
    r_axis_ARESETn  = 1'b1;
    #10
    r_axis_TVALID   = 1'b1;
    r_axis_TDATA    = 8'h33;
    #8
    r_axis_TVALID   = 1'b1;
    r_axis_TDATA    = 8'h44;
    #8
    r_axis_TVALID   = 1'b1;
    r_axis_TDATA    = 8'h55;
    #8
    r_axis_TVALID   = 1'b1;
    r_axis_TDATA    = 8'h66;
    #8
    r_axis_TVALID   = 1'b0;
    #8
    #100
    $finish;
  end

endmodule
