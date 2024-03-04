module sakebi_rmii_rx #(
  parameter DATA_WIDTH = 8
) (
// RMII RX INTERFACE
  input  wire                   i_rmii_REF_CLK,
  input  wire                   i_rmii_CRS_DV,
  input  wire [1:0]             i_rmii_RXD,
// AXI-Stream TX INTERFACE
  input  wire                   i_axis_ACLK,
  input  wire                   i_axis_ARESETn,
  output reg                    o_axis_TVALID,
  input  wire                   i_axis_TREADY,
  output reg  [DATA_WIDTH-1:0]  o_axis_TDATA
);

  reg                   r_crs_dv;
  reg [1:0]             r_rxd;
  reg [DATA_WIDTH-1:0]  r_byte_fifo;
  reg [DATA_WIDTH-1:0]  r_byte_cnt;

  reg                   r_afifo_wr_en;
  reg [DATA_WIDTH-1:0]  r_afifo_wr_data;

  // input buffers
  always @(posedge i_rmii_REF_CLK) begin
    r_crs_dv    <= i_rmii_CRS_DV;
    r_rxd       <= i_rmii_RXD; 
  end

  reg [3:0] r_rmii_state;
  localparam RMII_IDLE      = 4'h0;
  localparam RMII_PREAMBLE  = 4'b1;
  localparam RMII_SFD       = 4'h2;
  localparam RMII_DATA      = 4'h3;
  localparam RMII_ERROR     = 4'hf;

  always @(posedge i_rmii_REF_CLK) begin
    if(~i_axis_ARESETn) begin
      r_rmii_state      <= RMII_IDLE;
      r_byte_fifo       <= 8'h0;
      r_byte_cnt        <= 8'h0;
      r_afifo_wr_data   <= 8'h0;
      r_afifo_wr_en     <= 1'b0;
    end else begin
      case(r_rmii_state) 
        // wait for carrier
        RMII_IDLE     : begin
          r_byte_fifo       <= 8'h0;
          r_byte_cnt        <= 8'h0;
          r_afifo_wr_data   <= 8'h0;
          r_afifo_wr_en     <= 1'b0;
          if(r_crs_dv == 1'b1) begin
            r_rmii_state  <= RMII_PREAMBLE;
          end else begin
            r_rmii_state  <= r_rmii_state;
          end
        end
        // wait for preamble
        RMII_PREAMBLE : begin
          if(r_rxd == 2'b01) begin
            r_rmii_state  <= RMII_SFD;
          end else if(r_rxd == 2'b10) begin   // bad ssd
            r_rmii_state  <= RMII_ERROR;
          end else begin
            r_rmii_state  <= r_rmii_state;
          end
        end
        // wait for SFD
        RMII_SFD : begin
          if(r_rxd == 2'b11) begin    // sfd
            r_byte_cnt    <= 8'h00;
            r_rmii_state  <= RMII_DATA;
          end else if(r_rxd == 2'b01) begin
            r_rmii_state  <= r_rmii_state;
          end else begin
            r_rmii_state  <= RMII_ERROR;
          end
        end
        // accumlate data and send byte to next module
        // now r_rxd has valid data
        RMII_DATA : begin
          if(r_crs_dv == 1'b1) begin
            r_byte_fifo     <= {r_rxd, r_byte_fifo[7:2]};
            if(r_byte_cnt == 8'h04) begin
              r_byte_cnt        <= 8'h01;
              r_afifo_wr_data   <= r_byte_fifo;
              r_afifo_wr_en     <= 1'b1;
            end else begin
              r_byte_cnt        <= r_byte_cnt + 8'h01;
              r_afifo_wr_data   <= r_afifo_wr_data;
              r_afifo_wr_en     <= 1'b0;
            end
            r_rmii_state    <= r_rmii_state;
          end else begin
            r_afifo_wr_data <= r_byte_fifo;
            r_afifo_wr_en   <= 1'b1;
            r_rmii_state    <= RMII_IDLE;
          end
        end
        // error
        RMII_ERROR    : begin
          if(r_crs_dv == 1'b0) begin
            r_rmii_state    <= RMII_IDLE;
          end else begin
            r_rmii_state    <= r_rmii_state;
          end
        end
        default       : begin
          r_rmii_state  <= RMII_ERROR;
        end
      endcase
    end
  end

  wire                  w_afifo_rd_ready;
  reg                   r_afifo_rd_en;
  wire [DATA_WIDTH-1:0] w_afifo_rd_data;

  sakebi_async_fifo afifo(
    // WRITE
    .i_wr_clk   (i_rmii_REF_CLK     ),
    .i_wr_rstn  (1'b1               ),
    .o_wr_ready (),
    .i_wr_en    (r_afifo_wr_en      ),
    .i_wr_data  (r_afifo_wr_data    ),
    // READ
    .i_rd_clk   (i_axis_ACLK        ),
    .i_rd_rstn  (i_axis_ARESETn     ),
    .o_rd_ready (w_afifo_rd_ready   ),
    .i_rd_en    (r_afifo_rd_en      ),
    .o_rd_data  (w_afifo_rd_data    )
  );

  // valid signal extension for async fifo
  reg r_afifo_rd_valid;
  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(~i_axis_ARESETn) begin
      r_afifo_rd_valid  <= 1'b0;
    end else begin
      // when rd_ready, if assert rd_en then we got valid data
      if(w_afifo_rd_ready) begin
        r_afifo_rd_valid    <= r_afifo_rd_en;
      end else begin
        r_afifo_rd_valid    <= 1'b0;
      end
    end
  end

  // AXIS
  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    // read data from afifo
    if(~i_axis_ARESETn) begin
      r_afifo_rd_en <= 1'b0;
    end else begin
      if(w_afifo_rd_ready) begin
        r_afifo_rd_en   <= 1'b1;
      end else begin
        r_afifo_rd_en   <= 1'b0;
      end
    end
    // send data to AXIS
    if(~i_axis_ARESETn) begin
      o_axis_TVALID <= 1'b0;
      o_axis_TDATA  <= {DATA_WIDTH{1'b0}};
    end else begin
      if(r_afifo_rd_valid) begin
        o_axis_TVALID   <= 1'b1;
        o_axis_TDATA    <= w_afifo_rd_data;
      end else begin
        o_axis_TVALID   <= 1'b0;
        o_axis_TDATA    <= {DATA_WIDTH{1'b0}};
      end
    end
  end

endmodule
