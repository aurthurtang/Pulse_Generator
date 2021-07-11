module tb();

localparam real CLK_FREQ = 2000.0;
localparam CLK_PERIOD = (1/CLK_FREQ) * 1000;
localparam DATA_WIDTH = 64;
reg clk;
reg rstb;
reg pulse_in;
reg [DATA_WIDTH-1:0] pulse_out;

//Generate clock
initial begin
clk = 0;
forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
  $recordfile("tb.trn");
  $recordvars();
  pulse_in <= 1'b0;  
  rstb = 0;
//  i <= 0;
  #1000;
  rstb = 1;

  @(posedge clk);
  pulse_in <= 1'b1;
  @(posedge clk);
  pulse_in <= 1'b0;

 #10000;
 $finish;
end

pulse_gen #(
.CLK_FREQ (CLK_FREQ),
.DATA_WIDTH (DATA_WIDTH),
.PULSE_WIDTH (6.4)
) IDUT (
  .clk (clk),
  .rstb (rstb),
  .i_pulse (pulse_in),
  .o_pulse (pulse_out)
);

endmodule
