//File that will describe our stage latching.
//Each stage latch will have its own module.
import types::*;
//import mux_types::*; don't need to declare this

module IF_ID (
  input logic clk,

  input logic load, //this is used for stall
  input logic reset,
  input rv32i_word pcplus4_i, //pc+4
  input rv32i_word pc_i,
  input rv32i_word ir_i,
  output rv32i_word pcplus4_o,
  output rv32i_word pc_o,
  //IR outputs
  output logic [2:0] funct3_o,
  output logic [6:0] funct7_o,
  output rv32i_opcode opcode_o,
  output rv32i_word i_imm_o,
  output rv32i_word s_imm_o,
  output rv32i_word b_imm_o,
  output rv32i_word u_imm_o,
  output rv32i_word j_imm_o,
  output rv32i_reg rs1_o,
  output rv32i_reg rs2_o,
  output rv32i_reg rd_o
);
//in between logics for receiving inputs
rv32i_word pcplus4;
rv32i_word pc;
rv32i_word ir_in;

//outputs from IR module
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode;
rv32i_word i_imm;
rv32i_word s_imm;
rv32i_word b_imm;
rv32i_word u_imm;
rv32i_word j_imm;
rv32i_reg rs1;
rv32i_reg rs2;
rv32i_reg rd;

//logic initializations
// initial begin
//   pcplus4 = 32'd0;
//   pc = 32'd0;
//   ir_in = 32'd0;
// end

ir IR (
  .clk(clk),
  .load(load),
  .in(ir_in),
  .*  //this module will output to the logics declared above
);

//clock driven latching for input
always_ff @(posedge clk) begin
//assuming active high load
  if(load == 1'b1) begin
    pcplus4 <= pcplus4_i;
    pc <= pc_i;
    ir_in <= ir_i;
  end
end

//combinational output logic
always_comb begin
//  if(reset == 1'b1) begin
//    pcplus4 = 32'd0;
//    pc = 32'd0;
//    ir_in = 32'd0;
//  end
//  else begin
    pcplus4_o = pcplus4;
    pc_o = pc;
    //now do IR outputs
    funct3_o = funct3;
    funct7_o = funct7;
    opcode_o = opcode;
    i_imm_o = i_imm;
    s_imm_o = s_imm;
    b_imm_o = b_imm;
    u_imm_o = u_imm;
    j_imm_o = j_imm;
    rs1_o = rs1;
    rs2_o = rs2;
    rd_o = rd;
//  end
end

endmodule : IF_ID


module ID_EX (
  input logic clk,
  input logic load,
  input logic reset,
  input rv32i_word pcplus4_i,
  input rv32i_word pc_i,
  input rv32i_word rs1_i,
  input rv32i_word rs2_i,
  input rv32i_word imm_i,
  input logic alu_src_i,
  input alu_ops alu_op_i,
  input logic jmp_sel_i,
  input logic ld_i,
  input logic st_i,
  input logic br_i,
  input logic jmp_i,
  input rv32i_reg rd_i,

  output rv32i_word pcplus4_o,
  output rv32i_word pc_o,
  output rv32i_word rs1_o,
  output rv32i_word rs2_o,
  output rv32i_word imm_o,
  output logic alu_src_o,
  output alu_ops alu_op_o,
  output logic jmp_sel_o,
  output logic ld_o,
  output logic st_o,
  output logic br_o,
  output logic jmp_o,
  output rv32i_reg rd_o

);
//in between logics
rv32i_word pcplus4;
rv32i_word pc;
rv32i_word rs1;
rv32i_word rs2;
rv32i_word imm;
logic alu_src;
alu_ops alu_op;
logic jmp_sel;
logic ld;
logic st;
logic br;
logic jmp;
rv32i_reg rd;
//logic initializations
// initial begin
//   pcplus4 = 32'b0;
//   pc = 32'b0;
//   rs1 = 32'b0;
//   rs2 = 32'b0;
//   imm = 32'b0;
//   alu_src = 1'b0;
//   alu_op = alu_ops'(3'b0);	//needed cast
//   jmp_sel = 1'b0;
//   ld = 1'b0;
//   st = 1'b0;
//   br = 1'b0;
//   jmp = 1'b0;
//   rd = 5'b0;
// end

//clock driven latching for input
always_ff @(posedge clk) begin
  if (load == 1'b1) begin
      pcplus4 <= pcplus4_i;
      pc <= pc_i;
      rs1 <= rs1_i;
      rs2 <= rs2_i;
      imm <= imm_i;
      alu_src <= alu_src_i;
      alu_op <= alu_op_i;
      jmp_sel <= jmp_sel_i;
      ld <= ld_i;
      st <= st_i;
      br <= br_i;
      jmp <= jmp_i;
      rd <= rd_i;
  end
end

//combinational output logic
always_comb begin //implement reset signals
  pcplus4_o = pcplus4;
  pc_o = pc;
  rs1_o = rs1;
  rs2_o = rs2;
  imm_o = imm;
  alu_src_o = alu_src;
  alu_op_o = alu_op;
  jmp_sel_o = jmp_sel;
  ld_o = ld;
  st_o = st;
  br_o = br;
  jmp_o = jmp;
  rd_o = rd;
end

endmodule : ID_EX


module EX_MEM (
  input logic clk,
  input logic load,
  input logic reset,
  input rv32i_word pcplus4_i,
  input rv32i_word br_out_i,
  input rv32i_word rs2_i,
  input rv32i_word alu_out_i,
  input logic jmp_sel_i,
  input logic ld_i,
  input logic st_i,
  input logic br_i,
  input logic jmp_i,
  input rv32i_reg rd_i,

  output rv32i_word pcplus4_o,
  output rv32i_word br_out_o,
  output rv32i_word rs2_o,
  output rv32i_word alu_out_o,
  output logic jmp_sel_o,
  output logic ld_o,
  output logic st_o,
  output logic br_o,
  output logic jmp_o,
  output rv32i_reg rd_o
);
//in between logics
rv32i_word pcplus4;
rv32i_word br_out;
rv32i_word rs2;
rv32i_word alu_out;
logic jmp_sel, ld, st, br, jmp;
rv32i_reg rd;

//logic initializations
// initial begin
// 	pcplus4 = 32'd0;
// 	br_out = 32'd0;
// 	rs2 = 32'd0;
// 	alu_out = 32'd0;
// 	jmp_sel = 1'd0;
// 	ld = 1'd0;
// 	st = 1'd0;
// 	br = 1'd0;
// 	jmp = 1'd0;
// 	rd = 5'd0;
// end

//clock driven latching for input
always_ff @(posedge clk) begin
	pcplus4 <= pcplus4_i;
	br_out <= br_out_i;
	rs2 <= rs2_i;
	alu_out <= alu_out_i;
	jmp_sel <= jmp_sel_i;
	ld <= ld_i;
	st <= st_i;
	br <= br_i;
	jmp <= jmp_i;
	rd <= rd_i;	//added this in
end

//combinational output logic
always_comb begin
	pcplus4_o = pcplus4;
	br_out_o = br_out;
	rs2_o = rs2;
	alu_out_o = alu_out;
	jmp_sel_o = jmp_sel;
	ld_o = ld;
	st_o = st;
	br_o = br;
	jmp_o = jmp;
	rd_o = rd;
end

endmodule : EX_MEM


module MEM_WB (
  input logic clk,
  input logic load,
  input logic reset,
  input rv32i_word pcplus4_i,
  input rv32i_word rdata_i,
  input rv32i_word alu_out_i,
  input logic ld_i,
  input logic st_i,
  input logic jmp_i,
  input rv32i_reg rd_i,

  output rv32i_word pcplus4_o,
  output rv32i_word rdata_o,
  output rv32i_word alu_out_o,
  output logic ld_o,
  output logic st_o,
  output logic jmp_o,
  output rv32i_reg rd_o
);

rv32i_word pcplus4;
rv32i_word rdata;
rv32i_word alu_out;
logic ld, st, jmp;
rv32i_reg rd;

//logic initializations
// initial begin
// 	pcplus4 = 32'd0;
// 	rdata = 32'd0;
// 	alu_out = 32'd0;
// 	ld = 1'd0;
// 	st = 1'd0;
// 	jmp = 1'd0;
// 	rd = 5'd0;
// end

//clock driven latching for input
always_ff @(posedge clk) begin
	pcplus4 <= pcplus4_i;
	rdata <= rdata_i;
	alu_out <= alu_out_i;
	ld <= ld_i;
	st <= st_i;
	jmp <= jmp_i;
	rd <= rd_i;
end

//combinational output logic
always_comb begin
	pcplus4_o = pcplus4;
	rdata_o = rdata;
	alu_out_o = alu_out;
	ld_o = ld;
	st_o = st;
	jmp_o = jmp;
	rd_o = rd;
end

endmodule : MEM_WB
