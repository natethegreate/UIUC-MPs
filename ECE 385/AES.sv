/*---------------------------------------------------------------------------
  --      AES.sv                                                           --
  --      Joe Meng                                                         --
  --      Fall 2013                                                        --
  --                                                                       --
  --      Modified by Po-Han Huang 03/09/2017                              --
  --                                                                       --
  --      For use with ECE 385 Experiment 9                                --
  --      Spring 2017 Distribution                                         --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/

// AES decryption core.

// AES module interface with all ports, commented for Week 1
module  AES ( input                 clk, 
                                     reset_n,
                                     run,
               input        [127:0]  msg_en,
                                     key,
               output logic [127:0]  msg_de,
               output logic          ready,
					input						 cont);

// Partial interface for Week 1
// Splitting the signals into 32-bit ones for compatibility with ModelSim
//module  AES ( input                clk,
//              input        [31:0]  key_0, key_1, key_2, key_3,
//              output logic [31:0]  keyschedule_out_0, keyschedule_out_1, keyschedule_out_2, keyschedule_out_3 );      
enum logic [4:0] {START, LOAD, InvAdd_Start, InvAdd, InvShift, InvSub, InvMix_0, InvMix_1, InvMix_2, InvMix_3, InvMix_4,
						DONE, pause0, pause1, pause2, pause3, pause4, pausex0, pausex1, pausex2, pausex3, pausex4, STATE1, STATE2} state, next_state;
		
logic [1407:0] keyschedule; 
logic [127:0] msg_de_in, invadd_out, invshift_out, invsub_out, invmix_out, MUXOUT;
logic [31:0] mux_out, invmixbyte_out;
logic [3:0] round, round_in;
logic	[2:0] Select;
logic [1:0] col;
logic start;

assign msg_de = msg_de_in;
      
KeyExpansion keyexpansion_0(.clk(clk), 
                            .Cipherkey(key),
                            .KeySchedule(keyschedule)
                            );
									 
InvAddRoundKey invaddroundkey (msg_de_in, keyschedule, round, invadd_out);
InvShiftRows	invshiftrows	(msg_de_in, invshift_out);
InvSubBytes		invsubBytes_0	(clk, msg_de_in[7:0], invsub_out[7:0]);
InvSubBytes		invsubBytes_1	(clk, msg_de_in[15:8], invsub_out[15:8]);
InvSubBytes		invsubBytes_2	(clk, msg_de_in[23:16], invsub_out[23:16]);
InvSubBytes		invsubBytes_3	(clk, msg_de_in[31:24], invsub_out[31:24]);
InvSubBytes		invsubBytes_4	(clk, msg_de_in[39:32], invsub_out[39:32]);
InvSubBytes		invsubBytes_5	(clk, msg_de_in[47:40], invsub_out[47:40]);
InvSubBytes		invsubBytes_6	(clk, msg_de_in[55:48], invsub_out[55:48]);
InvSubBytes		invsubBytes_7	(clk, msg_de_in[63:56], invsub_out[63:56]);
InvSubBytes		invsubBytes_8	(clk, msg_de_in[71:64], invsub_out[71:64]);
InvSubBytes		invsubBytes_9	(clk, msg_de_in[79:72], invsub_out[79:72]);
InvSubBytes		invsubBytes_10	(clk, msg_de_in[87:80], invsub_out[87:80]);
InvSubBytes		invsubBytes_11 (clk, msg_de_in[96:88], invsub_out[96:88]);
InvSubBytes		invsubBytes_12	(clk, msg_de_in[103:96], invsub_out[103:96]);
InvSubBytes		invsubBytes_13	(clk, msg_de_in[111:104], invsub_out[111:104]);
InvSubBytes		invsubBytes_14	(clk, msg_de_in[119:112], invsub_out[119:112]);
InvSubBytes		invsubBytes_15	(clk, msg_de_in[127:120], invsub_out[127:120]);
mux32 			mux_32			(msg_de_in[127:96], msg_de_in[95:64], msg_de_in[63:32], msg_de_in[31:0], col, mux_out);
InvMixColumns	invmixColumns	(mux_out, invmixbyte_out);
selector			selector128		(clk, invmixbyte_out, col, invmix_out[127:96], invmix_out[95:64], invmix_out[63:32], invmix_out[31:0]);
mux128			mux_128			(invshift_out, invsub_out, invadd_out, invmix_out, msg_de_in, Select, MUXOUT);

 
//assign {keyschedule_out_0, keyschedule_out_1, keyschedule_out_2, keyschedule_out_3} = keyschedule[127:0];

// For week 2, write your own state machine here for AES decryption process.


	always_ff @ (posedge clk) begin
        if(reset_n == 1'b0) begin
				state <= START;
				round <= 4'b0;
        end
        else begin
				state <= next_state;
				round <= round_in;
				if(start)
						msg_de_in <= msg_en;
				else
						msg_de_in <= MUXOUT;
        end
	end

	always_comb begin
        // Next state logic
        next_state = state;
        unique case (state)
				START:
					if (run)
						next_state = LOAD;
				LOAD: begin
					if (run)
						next_state = InvAdd_Start;
				end
            InvAdd_Start: begin
//					next_state = InvShift;
					next_state = pausex0;
				end
				pausex0: begin
//					if (~cont)
						next_state = pause0;
				end
				pause0: begin
//					if (cont)
						next_state = InvShift;
				end
				InvShift: begin
//					next_state = InvSub;
					next_state = pausex1;
				end
				pausex1: begin
//					if (~cont)
						next_state = pause1;
				end
				pause1: begin
//					if (cont)
						next_state = InvSub;
				end
				InvSub: begin
//					next_state = InvAdd;
					next_state = pausex2;
				end
				pausex2: begin
//					if (~cont)
						next_state = pause2;
				end
				pause2: begin
//					if (cont)
						next_state = InvAdd;
				end
				InvAdd: begin
					if (round == 4'b1010)
						next_state = DONE;
					else
//						next_state = InvMix_0;
						next_state = pausex3;
				end
				pausex3: begin
//					if (~cont)
						next_state = pause3;
				end
				pause3: begin
//					if (cont)
						next_state = InvMix_0;
				end
				InvMix_0: begin
					next_state = InvMix_1;
				end
				InvMix_1: begin
					next_state = InvMix_2;
				end
				InvMix_2: begin
					next_state = InvMix_3;
				end
				InvMix_3: begin
					next_state = InvMix_4;
				end
				InvMix_4: begin
//					next_state = InvShift;
					next_state = pausex4;
				end
				pausex4: begin
//					if (~cont)
						next_state = pause4;
				end
				pause4: begin
//					if (cont)
						next_state = InvShift;
				end
				DONE: 
						next_state = STATE1;
				STATE1: begin
						next_state = STATE2;
				end
				STATE2: begin
						next_state = START;
				end
			endcase	
			
			Select = 3'b100;
			col = 2'b00;
			round_in = round;
			ready = 1'b0;
			start = 1'b0;
			case (state)
				START: begin
					round_in = 4'd0;
				end
				LOAD: begin
					start = 1'b1;
				end
				InvShift: begin
					Select = 3'b000;
				end
				InvSub: begin
					Select = 3'b001;
				end
				InvAdd_Start: begin
					Select = 3'b010;
					round_in = round + 4'b1;
				end
				InvAdd: begin
					Select = 3'b010;
				end
				InvMix_4: begin
					Select = 3'b011;
					round_in = round + 4'b1;
				end
				InvMix_0: begin
					col = 2'b00;
				end
				InvMix_1:begin
					col = 2'b01;
				end
				InvMix_2: begin
					col = 2'b10;
				end
				InvMix_3:begin
					col = 2'b11;
				end
				DONE: begin
					ready = 1'b1;
				end
				default:;
			endcase				
	end      
endmodule