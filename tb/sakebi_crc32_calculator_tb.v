module sakebi_crc32_calculator_tb;

  parameter DATA_WIDTH      = 8;
  parameter CRC_WIDTH       = 32;
  parameter INPUT_WIDTH     = DATA_WIDTH * 5;
  parameter OUTPUT_WIDTH    = DATA_WIDTH * 4;
  parameter CRC             = 32'h04C11DB7;

  reg                       i_clk   = 1'b0;
  reg   [INPUT_WIDTH-1:0]   i_data; 
  wire  [OUTPUT_WIDTH-1:0]  o_data;

  always #1 begin
    i_clk   <= ~i_clk;
  end

  sakebi_crc32_calculator #(
    .DATA_WIDTH     (DATA_WIDTH     ),
    .CRC_WIDTH      (CRC_WIDTH      ),
    .INPUT_WIDTH    (INPUT_WIDTH    ),
    .OUTPUT_WIDTH   (OUTPUT_WIDTH   ),
    .CRC            (CRC            )
  ) DUT (
    .i_clk  (i_clk  ),
    .i_data (i_data ),
    .o_data (o_data )
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, DUT);
  end

  initial begin
    i_data  = 40'h8888_8888_77;
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {~o_data, 8'h00};
    #2
    $finish;
  end

endmodule
