module blink
  #(parameter clk_freq_hz = 0)
   (input logic clk,
    input logic rst_n,
    output logic sig
   );

   logic [$clog2(clk_freq_hz)-1:0] counter;
   logic sig_reg;

   always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
          counter <= 0;
          sig_reg <= 1'b0;
      end else begin
          counter <= counter + 1;
          if (counter == clk_freq_hz-1) begin
	          sig_reg <= ~sig_reg;
	          counter <= 0;
          end
      end
   end


  assign sig = sig_reg;

endmodule

