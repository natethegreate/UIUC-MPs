package imm_mux;
typedef enum bit [2:0] {
	i_imm = 3'b000,
	j_imm = 3'b001,
	b_imm = 3'b010,
	s_imm = 3'b011,
	u_imm = 3'b100
} imm_mux;
endpackage

package alu_mux;
/* Input for arg 2 into the ALU */
typedef enum bit [0:0] {
	rs2  = 1'b0,
	imm = 1'b1
} alu_mux_i;

/* Output into alu_out */
typedef enum bit [1:0] {
	alu   = 2'b00,
	cmp   = 2'b01,
	u_imm = 2'b10
} alu_mux_o;
endpackage

package brj_mux;
typedef enum bit [0:0] {
	br_out = 1'b0,
	jalr   = 1'b1
} brj_mux;
endpackage

package  pc_mux;
typedef enum bit [0:0] {
	pc_alu_out  = 1'b0,
	brj_mux_out = 1'b1
} pc_mux;
endpackage

package wb_mux;
typedef enum bit [1:0] {
	alu_out = 2'b00,
	rdata 	= 2'b01,
	pcplus4	= 2'b10
} wb_mux;
endpackage
