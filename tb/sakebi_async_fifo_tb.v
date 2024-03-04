module sakebi_async_fifo_tb;

  reg r_wr_clk = 1'b0;
  reg r_rd_clk = 1'b0;

  wire w_wr_ready;
  wire w_rd_ready;

  reg  [7:0]    r_wr_data   = 8'h00;
  reg           r_wr_en     = 1'b0;
  wire [7:0]    w_rd_data;
  reg           r_rd_en     = 1'b0;

  always #1 begin
    r_wr_clk <= ~r_wr_clk;
  end

  always #4 begin
    r_rd_clk <= ~r_rd_clk;
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, DUT);
  end

  sakebi_async_fifo DUT(
    // WRITE
    .i_wr_clk   (r_wr_clk   ),
    .i_wr_rstn  (1'b1       ),
    .o_wr_ready (w_wr_ready ),
    .i_wr_en    (r_wr_en    ),
    .i_wr_data  (r_wr_data  ),
    // READ
    .i_rd_clk   (r_rd_clk   ),
    .i_rd_rstn  (1'b1       ),
    .o_rd_ready (w_rd_ready ),
    .i_rd_en    (r_rd_en    ),
    .o_rd_data  (w_rd_data  )
  );

  initial begin
    #2
    r_wr_en = 1'b1;
    r_wr_data = 8'h55;
    #2
    r_wr_data = 8'haa;
    #2
    r_wr_data = 8'h11;
    #2
    r_wr_en = 1'b0;
    r_wr_data = 8'h00;
    #4
    r_rd_en = 1'b1;
    #32
    r_rd_en = 1'b0;
    #100
    $finish;
  end
  
endmodule
