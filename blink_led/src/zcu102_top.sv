module zcu102_top
  (input logic clk_125mhz_p,
   input logic clk_125mhz_n,
   input logic btn,
   output logic [7:0] led);

   logic clk_125mhz;
   logic rst_n;
   logic sig;

   IBUFDS ibufds
     (.I  (clk_125mhz_p),
      .IB (clk_125mhz_n),
      .O  (clk_125mhz));

   blink #(.clk_freq_hz (125_000_000)) u0
     (.clk   (clk_125mhz),
      .rst_n (rst_n),
      .sig   (sig));

   assign led = {sig, ~sig, sig, ~sig, sig, ~sig, sig, ~sig}; 
   assign rst_n = btn;

endmodule
