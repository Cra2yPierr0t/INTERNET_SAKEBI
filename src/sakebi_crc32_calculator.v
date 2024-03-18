module sakebi_crc32_calculator #(
  parameter DATA_WIDTH      = 8,
  parameter CRC_WIDTH       = 32,
  parameter INPUT_WIDTH     = DATA_WIDTH * 5,
  parameter OUTPUT_WIDTH    = DATA_WIDTH * 4,
  parameter CRC             = 32'h04C11DB7
) (
  input wire    i_clk,
  input wire    [INPUT_WIDTH-1:0]   i_data,
  output wire   [OUTPUT_WIDTH-1:0]  o_data
);

/* verilator lint_off UNOPTFLAT */
  wire [CRC_WIDTH-1:0]  w_inter_crc[DATA_WIDTH-1:0];
/* verilator lint_on UNOPTFLAT */

  generate
    genvar i;
    for(i = 0; i < DATA_WIDTH; i = i + 1) begin : GEN_CRC_CHAIN
      if(i == 0) begin
        assign w_inter_crc[0] = i_data[INPUT_WIDTH-2:INPUT_WIDTH-1-CRC_WIDTH] ^ (i_data[INPUT_WIDTH-1] ? CRC : {CRC_WIDTH{1'b0}});
      end else begin
        assign w_inter_crc[i] = {w_inter_crc[i-1][CRC_WIDTH-2:0], i_data[DATA_WIDTH-1-i]} ^ (w_inter_crc[i-1][CRC_WIDTH-1] ? CRC : {CRC_WIDTH{1'b0}});
      end
    end
  endgenerate

  assign o_data =  w_inter_crc[DATA_WIDTH-1][OUTPUT_WIDTH-1:0];

endmodule
