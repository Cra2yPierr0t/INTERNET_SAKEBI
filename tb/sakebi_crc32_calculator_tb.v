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

  function [7:0] reflector;
    input [7:0] i_data;
    begin
      reflector = {i_data[0], i_data[1], i_data[2], i_data[3], i_data[4], i_data[5], i_data[6], i_data[7]};
    end
  endfunction

  initial begin
    i_data  = {~{reflector(8'h12), reflector(8'h34), reflector(8'h56), reflector(8'h78)}, reflector(8'h9A)};
    #2
    i_data  = {o_data, reflector(8'hBC)};
    #2
    i_data  = {o_data, reflector(8'hDE)};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {o_data, 8'h00};
    #2
    i_data  = {~{reflector(o_data[DATA_WIDTH*1-1:DATA_WIDTH*0]), reflector(o_data[DATA_WIDTH*2-1:DATA_WIDTH*1]), reflector(o_data[DATA_WIDTH*3-1:DATA_WIDTH*2]), reflector(o_data[DATA_WIDTH*4-1:DATA_WIDTH*3])}, 8'h00};
    #2
    $finish;
  end

endmodule
