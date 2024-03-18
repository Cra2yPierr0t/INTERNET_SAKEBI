module sakebi_crc32_wrapper_tb;

  parameter DATA_WIDTH = 8;
  
  reg                   i_axis_ACLK     = 1'b0;
  reg                   i_axis_ARESETn  = 1'b1;

  reg                   i_axis_TVALID   = 1'b0;
  reg  [DATA_WIDTH-1:0] i_axis_TDATA;

  wire                      o_axis_TVALID;
  wire [DATA_WIDTH*4-1:0]   o_axis_TDATA;

  always #1 begin
    i_axis_ACLK <= ~i_axis_ACLK;
  end

  sakebi_crc32_wrapper DUT (
    .i_axis_ACLK    (i_axis_ACLK    ),
    .i_axis_ARESETn (i_axis_ARESETn ),
    .i_axis_TVALID  (i_axis_TVALID  ),
    .i_axis_TDATA   (i_axis_TDATA   ),
    .o_axis_TVALID  (o_axis_TVALID  ),
    .o_axis_TDATA   (o_axis_TDATA   )
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, DUT);
  end


  initial begin
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'h12;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'h34;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'h56;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'h78;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'h9A;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'hBC;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'hDE;
    #2
    i_axis_TVALID   = 1'b1;
    i_axis_TDATA    = 8'hF0;
    #2
    i_axis_TVALID   = 1'b0;
    #20
    $finish;
  end

endmodule
