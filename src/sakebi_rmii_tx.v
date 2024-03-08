module sakebi_rmii_tx #(
  parameter DATA_WIDTH = 8
) (
// RMII TX INTERFACE
  input wire                    i_rmii_REF_CLK,
  output reg                    o_rmii_TX_EN,
  output reg [1:0]              o_rmii_TXD,
// AXI-Stream RX INTERFACE
  input wire                    i_axis_ACLK,
  input wire                    i_axis_ARESETn,
  input wire                    i_axis_TVALID,
  output reg                    o_axis_TREADY,  // TODO: implement
  input wire [DATA_WIDTH-1:0]   i_axis_TDATA
);

  wire                  w_afifo_wr_ready;
  reg                   r_afifo_wr_en;
  reg [DATA_WIDTH-1:0]  r_afifo_wr_data;

  reg [DATA_WIDTH-1:0]  r_tdata;
  reg                   r_tvalid;

  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
      r_tdata   <= {DATA_WIDTH{1'b0}};
      r_tvalid  <= 1'b0;
    end else begin
      r_tdata   <= i_axis_TDATA;
      r_tvalid  <= i_axis_TVALID;
    end
  end

  // AXIS RX
  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
      r_afifo_wr_en   <= 1'b0;
      r_afifo_wr_data <= 0;
    end else begin
      if(r_tvalid) begin
        r_afifo_wr_en   <= 1'b1;
        r_afifo_wr_data <= r_tdata;
      end else begin
        r_afifo_wr_en   <= 1'b0;
        r_afifo_wr_data <= 0;
      end
    end
  end

  wire                  w_afifo_rd_ready;
  reg                   r_afifo_rd_en;
  wire [DATA_WIDTH-1:0] w_afifo_rd_data;

  sakebi_async_fifo #(
    .DEPTH  (16 )
  ) afifo (
    // WRITE
    .i_wr_clk   (i_axis_ACLK        ),
    .i_wr_rstn  (i_axis_ARESETn     ),
    .o_wr_ready (w_afifo_wr_ready   ),
    .i_wr_en    (r_afifo_wr_en      ),
    .i_wr_data  (r_afifo_wr_data    ),
    // READ
    .i_rd_clk   (i_rmii_REF_CLK     ),
    .i_rd_rstn  (1'b1               ),
    .o_rd_ready (w_afifo_rd_ready   ),
    .i_rd_en    (r_afifo_rd_en      ),
    .o_rd_data  (w_afifo_rd_data    )
  );

  reg [3:0] r_rmii_state;
  localparam RMII_IDLE      = 4'h0;
  localparam RMII_PREAMBLE  = 4'b1;
  localparam RMII_SFD       = 4'h2;
  localparam RMII_DATA      = 4'h3;
  localparam RMII_ERROR     = 4'hf;

  reg [DATA_WIDTH-1:0]  r_rmii_fifo;
  reg [7:0]             r_rmii_data_cnt;
  reg [7:0] r_rmii_preamble_cnt;
  
  // RMII TX
  always @(posedge i_rmii_REF_CLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
      o_rmii_TX_EN  <= 1'b0;
      o_rmii_TXD    <= 2'b00;
      r_afifo_rd_en <= 1'b0;
      r_rmii_state  <= RMII_IDLE;
    end else begin
      case(r_rmii_state)
        RMII_IDLE       : begin
          o_rmii_TX_EN  <= 1'b0;
          o_rmii_TXD    <= 2'b00;
          r_afifo_rd_en <= 1'b0;
          if(w_afifo_rd_ready) begin
            r_rmii_state    <= RMII_PREAMBLE;
          end else begin
            r_rmii_state    <= r_rmii_state;
          end
        end
        RMII_PREAMBLE   : begin
          o_rmii_TX_EN  <= 1'b1;
          o_rmii_TXD    <= 2'b01;
          if(r_rmii_preamble_cnt == 8'h1e) begin
            r_afifo_rd_en       <= 1'b1;
            r_rmii_state        <= RMII_SFD;
            r_rmii_preamble_cnt <= 8'h00;
          end else begin
            r_rmii_state        <= r_rmii_state;
            r_rmii_preamble_cnt <= r_rmii_preamble_cnt + 8'h01;
          end
        end
        RMII_SFD        : begin
          r_rmii_data_cnt   <= 8'h00;
          o_rmii_TX_EN      <= 1'b1;
          o_rmii_TXD        <= 2'b11;
          r_rmii_state      <= RMII_DATA;
          r_afifo_rd_en     <= 1'b0;
        end
        RMII_DATA       : begin
          if((r_rmii_data_cnt == 8'h03) && (w_afifo_rd_ready == 1'b0)) begin
            r_afifo_rd_en   <= 1'b0;
            r_rmii_state    <= RMII_IDLE;
            r_rmii_data_cnt <= 8'h00;
            o_rmii_TXD      <= r_rmii_fifo[1:0];
            r_rmii_fifo     <= {2'b00, r_rmii_fifo[7:2]};
          end else if(r_rmii_data_cnt == 8'h00) begin
            r_afifo_rd_en   <= 1'b0;
            r_rmii_state    <= r_rmii_state;
            r_rmii_data_cnt <= r_rmii_data_cnt + 8'h01;
            o_rmii_TXD      <= w_afifo_rd_data[1:0];
            r_rmii_fifo     <= {2'b00, w_afifo_rd_data[7:2]};
          end else if(r_rmii_data_cnt == 8'h03) begin
            r_afifo_rd_en   <= 1'b0;
            r_rmii_state    <= r_rmii_state;
            r_rmii_data_cnt <= 8'h00;
            o_rmii_TXD      <= r_rmii_fifo[1:0];
            r_rmii_fifo     <= {2'b00, r_rmii_fifo[7:2]};
          end else if(r_rmii_data_cnt == 8'h02) begin
            r_afifo_rd_en   <= w_afifo_rd_ready;
            r_rmii_state    <= r_rmii_state;
            r_rmii_data_cnt <= r_rmii_data_cnt + 8'h01;
            o_rmii_TXD      <= r_rmii_fifo[1:0];
            r_rmii_fifo     <= {2'b00, r_rmii_fifo[7:2]};
          end else begin
            r_afifo_rd_en   <= 1'b0;
            r_rmii_state    <= r_rmii_state;
            r_rmii_data_cnt <= r_rmii_data_cnt + 8'h01;
            o_rmii_TXD      <= r_rmii_fifo[1:0];
            r_rmii_fifo     <= {2'b00, r_rmii_fifo[7:2]};
          end
        end
        default         : begin
          r_rmii_state  <= RMII_IDLE;
        end
      endcase
    end
  end

endmodule
