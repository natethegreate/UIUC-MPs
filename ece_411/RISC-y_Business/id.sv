`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import types::*;

module instruction_decode
(
	input rv32i_opcode opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,

	/* Replace with mux specific types */
	output alu_mux::alu_mux_i alu_src,
	output alu_mux::alu_mux_o alu_out_sel,
	output types::alu_ops alu_op,
	output brj_mux::brj_mux jmp_sel,
	output logic ld, st,
	output logic br, jmp,
	output imm_mux::imm_mux imm_sel,
	output logic [3:0] wmask
);

//Logics
store_funct3_t store_funct3;
assign store_funct3 = store_funct3_t'(funct3);

/* Setting the default signals of the control ROM */
function void id_defaults();
	alu_src     = alu_mux::rs2;
	alu_out_sel = alu_mux::alu;
	alu_op      = alu_ops'(funct3);
	jmp_sel     = brj_mux::br_out;
	ld          = 1'b0;
	st          = 1'b0;
	br          = 1'b0;
	jmp         = 1'b0;
	imm_sel     = imm_mux::i_imm;
	wmask 		= 4'b0000;
endfunction


always_comb
begin
	/* Set the defaults */
	id_defaults();
	/* Set non-default signals, reg covered by default */
	case ( opcode )
		op_imm:
		begin
			alu_src = alu_mux::imm;
		end
		op_lui:
		begin
			imm_sel     = imm_mux::u_imm;
			alu_out_sel = alu_mux::u_imm;
		end
		op_auipc:
		begin
			imm_sel = imm_mux::u_imm;
			alu_src = alu_mux::imm;
		end
		op_jal:
		begin
			imm_sel = imm_mux::j_imm;
			jmp     = 1'b1;
		end
		op_jalr:
		begin
			alu_src     = alu_mux::imm;
			alu_out_sel = alu_mux::alu;
			jmp_sel     = brj_mux::jalr;
			jmp         = 1'b1;
		end
		op_br:
		begin
			imm_sel = imm_mux::b_imm;
			alu_out_sel = alu_mux::cmp;
			br = 1'b1;
		end
		op_load:
		begin
			alu_src = alu_mux::imm;
			ld = 1'b1;
		end
		op_store:
		begin
			imm_sel = imm_mux::s_imm;
			alu_src = alu_mux::imm; //changed from i_imm to imm
			st = 1'b1;
			case(store_funct3)
                sw: wmask = 4'b1111;
                sh: wmask = 4'b0011;
                sb: wmask = 4'b0001;
				default: wmask = 4'b0000;
			endcase
		end
		default : `BAD_MUX_SEL;
	endcase
end

endmodule 	

