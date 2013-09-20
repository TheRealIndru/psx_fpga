/* 18545 Fall 2013
 * Team PSX
 * 09-17-2013
 *
 * @MODULES:
 * spdif
 * bmc
 * 
 * @DESCRIPTION:
 * Implements the S/P DIF protocol used by the ADV7511 Chip on the VC707 board.
 * This is the standard for audio input for the HDMI port.
 *
 * @AUTHOR:
 * Michael Rosen
 * mrrosen
 *
 */



/* @MODULE: spdif
 * @DESCRIPTION:
 * Main S/P DIF Module
 */
module spdif(
	     input bit 	      clk, rst,
	     input bit [15:0] data,
	     input bit 	      valid,
	     output bit       spdif_out, rdy);

   /* Parameters */
   parameter PREAMBLE_B_0 8'hE8;
   parameter PREAMBLE_B_1 8'h17;
   parameter PREAMBLE_M_0 8'hE2;
   parameter PREAMBLE_M_1 8'h1D;
   parameter PREAMBLE_W_0 8'hE4;
   parameter PREAMBLE_W_1 8'h1B;

   /* Internal Lines */
   bit [31:0] 		      storad_data;
   bit [4:0] 		      stored_bits;
   bit 			      second_part, parity;
   
   bit 			      preamble, right_channel;
   bit [7:0] 		      preamble_bits;
   
   bit [8:0] 		      subframe_count;

   bit 			      bcm_out;
   
   /* Data storage register */
   always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
	 stored_data <= 28'b0;
	 stored_bits <= 5'b0;
	 second_part <= 1'b0;
	 parity <= 1'b0;
	 rdy <= 1'b1;
	 right_channel <= 1'b0;
      end
      else begin
	 if (valid) begin
	    stored_data <= {preamble_bits, 10'b0, data, 3'b0, ^data};
	    stored_bits <= 5'd31;
	    parity <= ^data;
	    rdy <= 1'b0;
	 end
	 else if (stored_bits != 5'b0) begin
	    second_part <= ~second_part;
	    
	    if (preamble | second_part) begin
	       stored_data <= {stored_data[30:0], 1'b0};
	       stored_bits <= stored_bits - 5'd1;
	    end
	 end
	 else begin
	    rdy <= 1'b1;
	    right_channel <= ~right_channel;
	 end
      end
   end

   /* Preamble logic */
   always_comb begin
      /* Defaults */
      preamble_bits = PREAMBLE_B_0;
      
      if (subframe_count == 10'b0) begin
	 if (parity) begin
	    preamble_bits = PREAMBLE_B_1;
	 end
	 else begin
	    preamble_bits = PREAMBLE_B_0;
	 end
      end
      else if (right_channel) begin
	 if (parity) begin
	    preamble_bits = PREAMBLE_W_1;
	 end
	 else begin
	    preamble_bits = PREAMBLE_W_0;
	 end
      end
      else begin
	 if (parity) begin
	    preamble_bits = PREAMBLE_M_1;
         end
         else begin
	    preamble_bits = PREAMBLE_M_0;
         end
      end // else: !if(right_channel)
   end // always_comb
   
   /* Subframe Count register */
   always @(posedge clk, posedge rst) begin
      if (rst) begin
	 subframe_count <= 9'b0;
      end
      else begin
	 if (stored_bits == 5'd1) begin
	    if (subframe_count < 9'd383) begin
	       subframe_count <= stored_bits + 9'd1;
	    end
	    else begin
	       subframe_count <= 9'd0;
	    end
	 end
      end // else: !if(rst)
   end // always @ (posedge clk, posedge rst)
   
   /* Performs BCM (Biphase Mark Code) on the data before transmission */
   bmc bmc0(.data(stored_data[27]),
	    .valid(~preamble),
	    .*);

   assign spdif_out = (preamble) ? stored_preamble[7] : bcm_out;
   
endmodule // spdif


/* @MODULE: bmc
 * @DESCRIPTION:
 * Biphase Mark Codes the incoming data as long as valid is asserted
 */
module bmc(
	   input bit  clk, rst,
	   input bit  data, valid,
	   output bit bcm_out);

   /* Part indicates whether its the second half of the bit in data */
   bit 		      second_part;
   
   always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
	 bcm_out <= 1'b0;
	 second_part <= 1'b0;
      end
      else begin
	 /* If the data on the line is valid, run the machine
	    otherwise, hold the current state */
	 if (valid) begin
	    second_part <= ~second_part;
	    
	    if (~second_part) begin
	       bcm_out <= ~bcm_out;
	    end
	    else if (in) begin
	       bcm_out <= ~bcm_out;
	    end
	 end
      end // else: !if(rst)
   end // always_ff @

endmodule // bcm


/* @COMMENTING COMPLETE; EOF */