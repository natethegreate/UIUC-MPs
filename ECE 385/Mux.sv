module mux32 (input [31:0] in0, in1, in2, in3,
				  input [1:0] select,
				  output logic [31:0] out);
	always_comb
	begin
		case (select)		  
			2'b00:
				out = in0;
			2'b01:
				out = in1;
			2'b10:
				out = in2;
			2'b11:
				out = in3;
		endcase
	end
endmodule

module mux128 (input [127:0] in0, in1, in2, in3, orig,
				  input [3:0] select,
				  output logic [127:0] out);
	always_comb
	begin
		case (select)		  
			3'b000:
				out = in0;
			3'b001:
				out = in1;
			3'b010:
				out = in2;
			3'b011:
				out = in3;
			default:
				out = orig;
		endcase
	end
endmodule

module selector (input 			clk,
					  input [31:0]	in, 
//					  input [31:0] data0, data1, data2, data3,
					  input [1:0]	select,
//					  input        change,
					  output	logic [31:0] out0, out1, out2, out3);
	always_ff @ (posedge clk)
	begin
		if(select == 2'b00)
		begin
			out0 <= in;
		end
		else if(select == 2'b01)
		begin
			out1 <= in;
		end
		else if(select == 2'b10)
		begin
			out2 <= in;
		end
		else if(select == 2'b11)
		begin
			out3 <= in;
		end
	end
	
//	always_comb
//	begin
//		case ({change,select})
//			3'b100:
//			begin
//				out0 = in;
//				out1 = data1;
//				out2 = data2;
//				out3 = data3;
//			end
//			3'b101:
//			begin
//				out0 = data0;
//				out1 = in;
//				out2 = data2;
//				out3 = data3;
//			end
//			3'b110:
//			begin
//				out0 = data0;
//				out1 = data1;
//				out2 = in;
//				out3 = data3;
//			end
//			3'b111:
//			begin
//				out0 = data0;
//				out1 = data1;
//				out2 = data2;
//				out3 = in;
//			end
//			default:
//			begin
//				out0 = data0;
//				out1 = data1;
//				out2 = data2;
//				out3 = data3;
//			end
//		endcase
//	end
endmodule
	