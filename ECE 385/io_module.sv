/*---------------------------------------------------------------------------
  --      io_module.sv                                                     --
  --      Christine Chen                                                   --
  --      10/23/2013                                                       --
  --                                                                       --
  --      Modified by Po-Han Huang 03/08/2017                              --
  --                                                                       --
  --      For use with ECE 385 Experiment 9                                --
  --      Spring 2017 Distribution                                         --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/
  
// Control the IOs to and from NIOS.
// Receive encrypted message and key from NIOS byte-by-byte,
//   and send back decrypted message to NIOS byte-by-byte after decryption is done.
module io_module (  input                clk,
                    input                reset_n,    // Active-low reset
                    output logic [1:0]   to_sw_sig,  // Hardware to software flag signal
                    output logic [7:0]   to_sw_port, // Hardware to software data port
                    input        [1:0]   to_hw_sig,  // Software to hardware flag signal
                    input        [7:0]   to_hw_port, // Software to hardware data port
                    output logic [127:0] msg_en,     // Encrypted message
                    output logic [127:0] key,        // Key
                    input        [127:0] msg_de,     // Decrypted message
                    output logic         io_ready,   // Ready for decryption
                    input                aes_ready   // Decryption complete
      );
 
    enum logic [6:0] { RESET, WAIT,
                       READ_MSG_0, READ_MSG_1, READ_MSG_2, READ_MSG_3, READ_MSG_4, READ_MSG_5, READ_MSG_6, READ_MSG_7,
                       READ_MSG_8, READ_MSG_9, READ_MSG_10, READ_MSG_11, READ_MSG_12, READ_MSG_13, READ_MSG_14, READ_MSG_15,
                       ACK_MSG_0, ACK_MSG_1, ACK_MSG_2, ACK_MSG_3, ACK_MSG_4, ACK_MSG_5, ACK_MSG_6, ACK_MSG_7,
                       ACK_MSG_8, ACK_MSG_9, ACK_MSG_10, ACK_MSG_11, ACK_MSG_12, ACK_MSG_13, ACK_MSG_14, ACK_MSG_15,
                       READ_KEY_0, READ_KEY_1, READ_KEY_2, READ_KEY_3, READ_KEY_4, READ_KEY_5, READ_KEY_6, READ_KEY_7,
                       READ_KEY_8, READ_KEY_9, READ_KEY_10, READ_KEY_11, READ_KEY_12, READ_KEY_13, READ_KEY_14, READ_KEY_15,
                       ACK_KEY_0, ACK_KEY_1, ACK_KEY_2, ACK_KEY_3, ACK_KEY_4, ACK_KEY_5, ACK_KEY_6, ACK_KEY_7,
                       ACK_KEY_8, ACK_KEY_9, ACK_KEY_10, ACK_KEY_11, ACK_KEY_12, ACK_KEY_13, ACK_KEY_14, ACK_KEY_15,
                       SEND_TO_AES, GET_FROM_AES,
                       SEND_BACK_0, SEND_BACK_1, SEND_BACK_2, SEND_BACK_3, SEND_BACK_4, SEND_BACK_5, SEND_BACK_6, SEND_BACK_7,
                       SEND_BACK_8, SEND_BACK_9, SEND_BACK_10, SEND_BACK_11, SEND_BACK_12, SEND_BACK_13, SEND_BACK_14, SEND_BACK_15,
                       GOT_ACK_0, GOT_ACK_1, GOT_ACK_2, GOT_ACK_3, GOT_ACK_4, GOT_ACK_5, GOT_ACK_6, GOT_ACK_7,
                       GOT_ACK_8, GOT_ACK_9, GOT_ACK_10, GOT_ACK_11, GOT_ACK_12, GOT_ACK_13, GOT_ACK_14, GOT_ACK_15
    } state, next_state;

    logic [127:0] msg_en_in, key_in;

    always_ff @ (posedge clk) begin
        if(reset_n == 1'b0) begin
            state <= RESET;
				msg_en <= 128'd0;
				key <= 128'd0;
        end
        else begin
            state <= next_state;
            msg_en <= msg_en_in;
            key <= key_in;
        end
		  
		  
		  unique case (state)
            READ_MSG_0: begin
                // Receiving the first byte of encrypted message
                msg_en_in[127:120] <= to_hw_port[7:0]; 
            end
            READ_MSG_1: begin
                // Receiving the second byte of encrypted message
                msg_en_in[119:112] <= to_hw_port[7:0];
            end
				READ_MSG_2: begin
                // Receiving the second byte of encrypted message
                msg_en_in[111:104] <= to_hw_port[7:0];
            end
				READ_MSG_3: begin
                // Receiving the second byte of encrypted message
                msg_en_in[103:96] <= to_hw_port[7:0];
            end
				READ_MSG_4: begin
                // Receiving the second byte of encrypted message
                msg_en_in[95:88] <= to_hw_port[7:0];
            end
				READ_MSG_5: begin
                // Receiving the second byte of encrypted message
                msg_en_in[87:80] <= to_hw_port[7:0];
            end
				READ_MSG_6: begin
                // Receiving the second byte of encrypted message
                msg_en_in[79:72] <= to_hw_port[7:0];
            end
				READ_MSG_7: begin
                // Receiving the second byte of encrypted message
                msg_en_in[71:64] <= to_hw_port[7:0];
            end
				READ_MSG_8: begin
                // Receiving the second byte of encrypted message
                msg_en_in[63:56] <= to_hw_port[7:0];
            end
				READ_MSG_9: begin
                // Receiving the second byte of encrypted message
                msg_en_in[55:48] <= to_hw_port[7:0];
            end
				READ_MSG_10: begin
                // Receiving the second byte of encrypted message
                msg_en_in[47:40] <= to_hw_port[7:0];
            end
				READ_MSG_11: begin
                // Receiving the second byte of encrypted message
                msg_en_in[39:32] <= to_hw_port[7:0];
            end
				READ_MSG_12: begin
                // Receiving the second byte of encrypted message
                msg_en_in[31:24] <= to_hw_port[7:0];
            end
				READ_MSG_13: begin
                // Receiving the second byte of encrypted message
                msg_en_in[23:16] <= to_hw_port[7:0];
            end
				READ_MSG_14: begin
                // Receiving the second byte of encrypted message
                msg_en_in[15:8] <= to_hw_port[7:0];
            end
				READ_MSG_15: begin
                // Receiving the second byte of encrypted message
                msg_en_in[7:0] <= to_hw_port[7:0];
            end

            // TODO: other states
				READ_KEY_0: begin
                key_in[127:120] <= to_hw_port[7:0];
            end
            READ_KEY_1: begin
                key_in[119:112] <= to_hw_port[7:0];
            end
				READ_KEY_2: begin
                key_in[111:104] <= to_hw_port[7:0];
            end
				READ_KEY_3: begin
                key_in[103:96] <= to_hw_port[7:0];
            end
				READ_KEY_4: begin
                key_in[95:88] <= to_hw_port[7:0];
            end
				READ_KEY_5: begin
                key_in[87:80] <= to_hw_port[7:0];
            end
				READ_KEY_6: begin
                key_in[79:72] <= to_hw_port[7:0];
            end
				READ_KEY_7: begin
                key_in[71:64] <= to_hw_port[7:0];
            end
				READ_KEY_8: begin
                key_in[63:56] <= to_hw_port[7:0];
            end
				READ_KEY_9: begin
                key_in[55:48] <= to_hw_port[7:0];
            end
				READ_KEY_10: begin
                key_in[47:40] <= to_hw_port[7:0];
            end
				READ_KEY_11: begin
                key_in[39:32] <= to_hw_port[7:0];
            end
				READ_KEY_12: begin
                key_in[31:24] <= to_hw_port[7:0];
            end
				READ_KEY_13: begin
                key_in[23:16] <= to_hw_port[7:0];
            end
				READ_KEY_14: begin
                key_in[15:8] <= to_hw_port[7:0];
            end
				READ_KEY_15: begin
                key_in[7:0] <= to_hw_port[7:0];
            end
				
				SEND_BACK_0: begin
                to_sw_port[7:0] <= msg_de[127:120];
            end
				SEND_BACK_1: begin
                to_sw_port[7:0] <= msg_de[119:112];
            end
				SEND_BACK_2: begin
                to_sw_port[7:0] <= msg_de[111:104];
            end
				SEND_BACK_3: begin
                to_sw_port[7:0] <= msg_de[103:96];
            end
				SEND_BACK_4: begin
                to_sw_port[7:0] <= msg_de[95:88];
            end
				SEND_BACK_5: begin
                to_sw_port[7:0] <= msg_de[87:80];
            end
				SEND_BACK_6: begin
                to_sw_port[7:0] <= msg_de[79:72];
            end
				SEND_BACK_7: begin
                to_sw_port[7:0] <= msg_de[71:64];
            end
				SEND_BACK_8: begin
                to_sw_port[7:0] <= msg_de[63:56];
            end
				SEND_BACK_9: begin
                to_sw_port[7:0] <= msg_de[55:48];
            end
				SEND_BACK_10: begin
                to_sw_port[7:0] <= msg_de[47:40];
            end
				SEND_BACK_11: begin
                to_sw_port[7:0] <= msg_de[39:32];
            end
				SEND_BACK_12: begin
                to_sw_port[7:0] <= msg_de[31:24];
            end
				SEND_BACK_13: begin
                to_sw_port[7:0] <= msg_de[23:16];
            end
				SEND_BACK_14: begin
                to_sw_port[7:0] <= msg_de[15:8];
            end
				SEND_BACK_15: begin
                to_sw_port[7:0] <= msg_de[7:0];
            end
		endcase
		  
		  
    end

    always_comb begin
        // Next state logic
        next_state = state;
        unique case (state)
            RESET: begin
                next_state = WAIT;
            end
            WAIT: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_0;
                else if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_0;
                else if (to_hw_sig == 2'd3)
                    next_state = SEND_TO_AES;
            end
            READ_MSG_0: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_0;
            end
            READ_MSG_1: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_1;
            end
				READ_MSG_2: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_2;
            end
				READ_MSG_3: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_3;
            end
				READ_MSG_4: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_4;
            end
				READ_MSG_5: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_5;
            end
				READ_MSG_6: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_6;
            end
				READ_MSG_7: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_7;
            end
				READ_MSG_8: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_8;
            end
				READ_MSG_9: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_9;
            end
				READ_MSG_10: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_10;
            end
				READ_MSG_11: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_11;
            end
				READ_MSG_12: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_12;
            end
				READ_MSG_13: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_13;
            end
				READ_MSG_14: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_14;
            end
				READ_MSG_15: begin
                if (to_hw_sig == 2'd2)
                    next_state = ACK_MSG_15;
            end
            ACK_MSG_0: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_1;
            end
            ACK_MSG_1: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_2;
            end
				ACK_MSG_2: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_3;
            end
            ACK_MSG_3: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_4;
            end
				ACK_MSG_4: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_5;
            end
            ACK_MSG_5: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_6;
            end
				ACK_MSG_6: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_7;
            end
            ACK_MSG_7: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_8;
            end
				ACK_MSG_8: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_9;
            end
            ACK_MSG_9: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_10;
            end
				ACK_MSG_10: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_11;
            end
            ACK_MSG_11: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_12;
            end
				ACK_MSG_12: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_13;
            end
            ACK_MSG_13: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_14;
            end
				ACK_MSG_14: begin
                if (to_hw_sig == 2'd1)
                    next_state = READ_MSG_15;
            end
            ACK_MSG_15: begin
                if (to_hw_sig == 2'd0)
                    next_state = WAIT;
            end

            // TODO: other states
				READ_KEY_0: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_0;
            end
				READ_KEY_1: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_1;
            end
				READ_KEY_2: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_2;
            end
				READ_KEY_3: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_3;
            end
				READ_KEY_4: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_4;
            end
				READ_KEY_5: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_5;
            end
				READ_KEY_6: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_6;
            end
				READ_KEY_7: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_7;
            end
				READ_KEY_8: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_8;
            end
				READ_KEY_9: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_9;
            end
				READ_KEY_10: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_10;
            end
				READ_KEY_11: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_11;
            end
				READ_KEY_12: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_12;
            end
				READ_KEY_13: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_13;
            end
				READ_KEY_14: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_14;
            end
				READ_KEY_15: begin
                if (to_hw_sig == 2'd1)
                    next_state = ACK_KEY_15;
            end
				
				ACK_KEY_0: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_1;
				end
				ACK_KEY_1: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_2;
				end		  
				ACK_KEY_2: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_3;
				end
				ACK_KEY_3: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_4;
				end
				ACK_KEY_4: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_5;
				end
				ACK_KEY_5: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_6;
				end
				ACK_KEY_6: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_7;
				end
				ACK_KEY_7: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_8;
				end
				ACK_KEY_8: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_9;
				end
				ACK_KEY_9: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_10;
				end
				ACK_KEY_10: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_11;
				end
				ACK_KEY_11: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_12;
				end
				ACK_KEY_12: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_13;
				end
				ACK_KEY_13: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_14;
				end
				ACK_KEY_14: begin
                if (to_hw_sig == 2'd2)
                    next_state = READ_KEY_15;
				end
				ACK_KEY_15: begin
                if (to_hw_sig == 2'd3)
                    next_state = WAIT;
				end
				//
				SEND_TO_AES: begin
                if (aes_ready == 2'd1)
                    next_state = GET_FROM_AES;
				end
				GET_FROM_AES: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_0;
				end
				SEND_BACK_0: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_0;
				end
				GOT_ACK_0: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_1;
				end
				SEND_BACK_1: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_1;
				end
				GOT_ACK_1: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_2;
				end
				SEND_BACK_2: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_2;
				end
				GOT_ACK_2: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_3;
				end
				SEND_BACK_3: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_3;
				end
				GOT_ACK_3: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_4;
				end
				SEND_BACK_4: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_4;
				end
				GOT_ACK_4: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_5;
				end
				SEND_BACK_5: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_5;
				end
				GOT_ACK_5: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_6;
				end
				SEND_BACK_6: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_6;
				end
				GOT_ACK_6: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_7;
				end
				SEND_BACK_7: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_7;
				end
				GOT_ACK_7: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_8;
				end
				SEND_BACK_8: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_8;
				end
				GOT_ACK_8: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_9;
				end
				SEND_BACK_9: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_9;
				end
				GOT_ACK_9: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_10;
				end
				SEND_BACK_10: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_10;
				end
				GOT_ACK_10: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_11;
				end
				SEND_BACK_11: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_11;
				end
				GOT_ACK_11: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_12;
				end
				SEND_BACK_12: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_12;
				end
				GOT_ACK_12: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_13;
				end
				SEND_BACK_13: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_13;
				end
				GOT_ACK_13: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_14;
				end
				SEND_BACK_14: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_14;
				end
				GOT_ACK_14: begin
                if (to_hw_sig == 2'd1)
                    next_state = SEND_BACK_15;
				end
				SEND_BACK_15: begin
                if (to_hw_sig == 2'd2)
                    next_state = GOT_ACK_15;
				end
				GOT_ACK_15: begin
                if (to_hw_sig == 2'd1)
                    next_state = WAIT;
				end
				

        endcase

        // Register inputs
        //msg_en_in = msg_en;
        //key_in = key;
        
				


        // Control signals
//        to_sw_port = 8'd0;
        to_sw_sig = 2'd0;
        io_ready = 1'b0;
        unique case (state)
            RESET: begin
                to_sw_sig = 2'd3;
            end
            WAIT: begin
                to_sw_sig = 2'd0;
            end
            READ_MSG_0, READ_MSG_1, READ_MSG_2, READ_MSG_3, READ_MSG_4, READ_MSG_5, READ_MSG_6, READ_MSG_7,
                       READ_MSG_8, READ_MSG_9, READ_MSG_10, READ_MSG_11, READ_MSG_12, READ_MSG_13, READ_MSG_14, READ_MSG_15,
				READ_KEY_0, READ_KEY_1, READ_KEY_2, READ_KEY_3, READ_KEY_4, READ_KEY_5, READ_KEY_6, READ_KEY_7,
                       READ_KEY_8, READ_KEY_9, READ_KEY_10, READ_KEY_11, READ_KEY_12, READ_KEY_13, READ_KEY_14, READ_KEY_15,
				SEND_BACK_0, SEND_BACK_1, SEND_BACK_2, SEND_BACK_3, SEND_BACK_4, SEND_BACK_5, SEND_BACK_6, SEND_BACK_7,
                       SEND_BACK_8, SEND_BACK_9, SEND_BACK_10, SEND_BACK_11, SEND_BACK_12, SEND_BACK_13, SEND_BACK_14, SEND_BACK_15:          
				begin
                to_sw_sig = 2'd1;
            end
            ACK_MSG_0, ACK_MSG_1, ACK_MSG_2, ACK_MSG_3, ACK_MSG_4, ACK_MSG_5, ACK_MSG_6, ACK_MSG_7,
                       ACK_MSG_8, ACK_MSG_9, ACK_MSG_10, ACK_MSG_11, ACK_MSG_12, ACK_MSG_13, ACK_MSG_14, ACK_MSG_15, 
				ACK_KEY_0, ACK_KEY_1, ACK_KEY_2, ACK_KEY_3, ACK_KEY_4, ACK_KEY_5, ACK_KEY_6, ACK_KEY_7,
                       ACK_KEY_8, ACK_KEY_9, ACK_KEY_10, ACK_KEY_11, ACK_KEY_12, ACK_KEY_13, ACK_KEY_14, ACK_KEY_15,
            GOT_ACK_0, GOT_ACK_1, GOT_ACK_2, GOT_ACK_3, GOT_ACK_4, GOT_ACK_5, GOT_ACK_6, GOT_ACK_7,
                       GOT_ACK_8, GOT_ACK_9, GOT_ACK_10, GOT_ACK_11, GOT_ACK_12, GOT_ACK_13, GOT_ACK_14, GOT_ACK_15:        
				begin
                to_sw_sig = 2'd0;
            end
            // ...some more states in between
            SEND_TO_AES: begin
                to_sw_sig = 2'd0;
                if(~aes_ready)
							io_ready = 1'b1;
            end
            // ...some more states in between
            GET_FROM_AES: begin
                to_sw_sig = 2'd2;
            end

            // TODO: other states

        endcase
    end
endmodule