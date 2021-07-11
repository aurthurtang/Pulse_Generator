///////////////////////////////////////////////////////////////////////
//
//  Pulse generation
//   
//   Stretch a pulse based on the clock frequency and expected pulse width
//   pulse cannot be less than the 1 sample clock period 
//
/////////////////////////////////////////////////////////////////////////
module pulse_gen #(
parameter real CLK_FREQ = 156.25,  //In Mhz
parameter      DATA_WIDTH = 64,   //Integer
parameter real PULSE_WIDTH = 6.4  //In Ns
) (
input  clk,
input  rstb,

input  i_pulse,
output reg [DATA_WIDTH-1:0] o_pulse
);

localparam IN_OUT_RATIO = PULSE_WIDTH / ((1/CLK_FREQ) * 1000);
localparam REMAINING_BITS = int'(IN_OUT_RATIO * DATA_WIDTH) % DATA_WIDTH;
localparam NUM_OF_CYCLE = int'(IN_OUT_RATIO);

logic i_pulse_reg;

wire pulse_re = ~i_pulse_reg & i_pulse;
reg  [$clog2(NUM_OF_CYCLE)-1:0] cycle_count;

//Print localparam
initial begin
  $display("Ratio: %f Remain Bits: %d Number of cycle: %d", IN_OUT_RATIO, REMAINING_BITS, NUM_OF_CYCLE);
end

//Edge detect for i_pulse.  Assuming that i_pulse is synchronous
always_ff @(posedge clk or negedge rstb)
  if (!rstb) i_pulse_reg <= 1'b0;
  else i_pulse_reg <= i_pulse;

//Simplify Version.  No FSM
always_ff @(posedge clk or negedge rstb)
  if (!rstb) begin
    o_pulse <= 'b0;
    cycle_count <= NUM_OF_CYCLE;
  end else begin
    if (pulse_re) cycle_count <= 'b0;

    if (cycle_count != NUM_OF_CYCLE) begin
      cycle_count <= cycle_count + 1;

      if (cycle_count != NUM_OF_CYCLE-1) o_pulse <= {DATA_WIDTH{1'b1}};
      else o_pulse <= (REMAINING_BITS == 0) ? {DATA_WIDTH{1'b1}} : {{REMAINING_BITS{1'b1}},{(DATA_WIDTH-REMAINING_BITS){1'b0}}};
    end else begin
      o_pulse <= 'b0;
    end
  end

endmodule





