module sakebi_crc32_wrapper #(
  parameter DATA_WIDTH      = 8
) (
  input wire                        i_axis_ACLK,
  input wire                        i_axis_ARESETn,
  // AXI-Stream Input Data
  input wire                        i_axis_TVALID,
  output reg                        o_axis_TREADY,
  input wire    [DATA_WIDTH-1:0]    i_axis_TDATA,
  // AXI-Stream Output Data
  output reg                        o_axis_TVALID,
  output reg    [DATA_WIDTH*4-1:0]  o_axis_TDATA
);

  parameter CRC_WIDTH       = 32;
  parameter INPUT_WIDTH     = DATA_WIDTH * 5;
  parameter OUTPUT_WIDTH    = DATA_WIDTH * 4;
  parameter CRC             = 32'h04C11DB7;

  reg [7:0]                 r_fifo_cnt = 8'h00;
  reg [DATA_WIDTH*5-1:0]    r_fifo;
  wire  [CRC_WIDTH-1:0]     w_crc;

  function [7:0] reflector;
    input [7:0] i_data;
    begin
      reflector = {i_data[0], i_data[1], i_data[2], i_data[3], i_data[4], i_data[5], i_data[6], i_data[7]};
    end
  endfunction

  function [DATA_WIDTH*4-1:0] output_reflector;
    input [DATA_WIDTH*4-1:0] i_data;
    begin
      output_reflector = {reflector(i_data[DATA_WIDTH-1:0]), reflector(i_data[DATA_WIDTH*2-1:DATA_WIDTH]), reflector(i_data[DATA_WIDTH*3-1:DATA_WIDTH*2]), reflector(i_data[DATA_WIDTH*4-1:DATA_WIDTH*3])};
    end
  endfunction

  reg [7:0] r_crc_state;

  localparam CRC_IDLE       = 8'h00;
  localparam CRC_FIRST4BYTE = 8'h01;
  localparam CRC_FOLLOWDATA = 8'h02;
  localparam CRC_ZEROS      = 8'h03;
  localparam CRC_SENDCRC    = 8'h04;

  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
      r_crc_state   <= CRC_IDLE;
      r_fifo_cnt    <= 8'h00;
      r_fifo        <= {DATA_WIDTH*5{1'b0}};
      o_axis_TDATA  <= {DATA_WIDTH*4{1'b0}};
      o_axis_TVALID <= 1'b0;
      o_axis_TREADY <= 1'b1;
    end else begin
      case(r_crc_state)
        CRC_IDLE        : begin
          o_axis_TREADY <= 1'b1;
          if(i_axis_TVALID) begin
            o_axis_TDATA    <= {DATA_WIDTH*4{1'b0}};
            o_axis_TVALID   <= 1'b0;
            r_crc_state     <= CRC_FIRST4BYTE;
            r_fifo_cnt      <= r_fifo_cnt + 8'h01;
            r_fifo          <= {r_fifo[DATA_WIDTH*4-1:0], ~reflector(i_axis_TDATA)};
          end else begin
            o_axis_TDATA    <= o_axis_TDATA;
            o_axis_TVALID   <= o_axis_TVALID;
            r_crc_state     <= CRC_IDLE;
            r_fifo_cnt      <= 8'h00;
            r_fifo          <= {DATA_WIDTH*5{1'b0}};
          end
        end
        CRC_FIRST4BYTE  : begin
          r_fifo    <= {r_fifo[DATA_WIDTH*4-1:0], ~reflector(i_axis_TDATA)};
          if(r_fifo_cnt == 8'h03) begin
            r_crc_state <= CRC_FOLLOWDATA;
            r_fifo_cnt  <= 8'h00;
          end else begin
            r_crc_state <= CRC_FIRST4BYTE;
            r_fifo_cnt  <= r_fifo_cnt + 8'h01;
          end
        end
        CRC_FOLLOWDATA  : begin
          if(i_axis_TVALID) begin
            r_crc_state <= CRC_FOLLOWDATA;
            r_fifo      <= {w_crc, reflector(i_axis_TDATA)};
          end else begin
            r_crc_state <= CRC_ZEROS;
            r_fifo      <= {w_crc, 8'h00};
            r_fifo_cnt  <= r_fifo_cnt + 8'h01;
            o_axis_TREADY <= 1'b0;
          end
        end
        CRC_ZEROS       : begin
          r_fifo    <= {w_crc, 8'h00};
          if(r_fifo_cnt == 8'h03) begin
            r_crc_state <= CRC_SENDCRC;
            r_fifo_cnt  <= 8'h00;
          end else begin
            r_crc_state <= CRC_ZEROS;
            r_fifo_cnt  <= r_fifo_cnt + 8'h01;
          end
        end
        CRC_SENDCRC     : begin
          r_crc_state   <= CRC_IDLE;
          o_axis_TVALID <= 1'b1;
          o_axis_TDATA  <= ~output_reflector(w_crc);
          o_axis_TREADY <= 1'b1;
        end
        default         : begin
          r_crc_state   <= CRC_IDLE;
        end
      endcase
    end
  end

  sakebi_crc32_calculator #(
    .DATA_WIDTH     (DATA_WIDTH     ),
    .CRC_WIDTH      (CRC_WIDTH      ),
    .INPUT_WIDTH    (INPUT_WIDTH    ),
    .OUTPUT_WIDTH   (OUTPUT_WIDTH   ),
    .CRC            (CRC            )
  ) crc32_calc (
    .i_clk  (i_axis_ACLK    ),
    .i_data (r_fifo         ),
    .o_data (w_crc          )
  );

endmodule
