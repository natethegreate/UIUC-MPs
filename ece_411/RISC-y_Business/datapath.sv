`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import types::*;
import mux_types::*;
//Module declaration here
module cpu_datapath
(
	input logic clk

	/* ICACHE INTERFACE */
	input  logic icache_resp,
	input  logic [31:0] icache_rdata,
	output logic icache_read,
	output logic [31:0] icache_address,

	/* DCACHE INTERFACE */
	input  logic dcache_resp,
	input  logic [31:0] dcache_rdata,
<<<<<<< HEAD

=======
>>>>>>> accident_branch
	output logic dcache_read,
	output logic dcache_write,
	output logic [3:0] dcache_wmask,
	output logic [31:0] dcache_wdata,
	output logic [31:0] dcache_address
);

//Stage 1: Fetch
//logic declaration

//pcmux signals
logic pcmux_sel_1;
rv32i_word pcmux_out_1;

//pc signals
rv32i_word PC_out_1;
logic load_pc;

//pc_alu signals
rv32i_word pc_alu_out_1;

//ICache signals
rv32i_word ICache_rdata_1;
logic magic_resp_1;
//dummy magic memory logics, dont use these
logic magic_resp_1_dead;
logic [31:0] magic_rdata_1_dead;

//Expected stage 4 declaration
//logic [31:0] brj_mux_out_4;
rv32i_word brj_mux_out_4;
logic br_4, jmp_4;
//assigns
assign pc_alu_out_1 = PC_out_1 + 32'd4;

assign load_pc = 1'b1;

/* ICACHE SIGNALS */
assign icache_address = PC_out_1;
assign icache_read = 1'b1;
//assign load_pc = br_detect;

//pcmux               sel bit       if sel=1        else sel=0
// assign pcmux_out_1 = (pcmux_sel_1 ? brj_mux_out_4 : pc_alu_out_1 );

//modules
pc_register PC (
  .clk		(clk),
	.load		(load_pc),
	.in		(pcmux_out_1),
	.out		(PC_out_1)
);

//pcmux
always_comb begin		//casting
  unique case (pcmux_sel_1)
    pc_mux::pc_alu_out : pcmux_out_1 = pc_alu_out_1;
    pc_mux::brj_mux_out : pcmux_out_1 = brj_mux_out_4;
  endcase
end

//Stage 2: Decode
//logic declaration
	/* ID input signals */
	rv32i_opcode IR_opcode_2;
	logic [2:0]  IR_funct3_2;
	logic [6:0]  IR_funct7_2;

	rv32i_word rs1_2; //needed these outputs?
	rv32i_word rs2_2;

	logic st_5;
	rv32i_reg rd_5;
	rv32i_word wbmux_out_5;
	logic reset = 1'b0;	//reset logic to flush pipeline

	/* ID output signals */
	alu_mux_i    alu_src_2;
	alu_mux_o    alu_out_sel_2;
	alu_ops      alu_op_2;
	brj_mux      jmp_sel_2;
	imm_mux      imm_sel_2;
	logic ld_2, st_2, br_2, jmp_2;

	/* IR immediate wires */
	logic [31:0] IR_i_imm_2, IR_j_imm_2, IR_b_imm_2,
                 IR_u_imm_2, IR_s_imm_2, imm_2;
	logic [2:0] IR_funct3_2;
	logic [6:0] IR_funct7_2;
	rv32i_opcode IR_opcode_2;
	logic [4:0] IR_rs1_2, IR_rs2_2, rd_2;

    /* IF ID latch declaration */

    rv32i_word pc_plus4_2; //changed this to 32 bits
    rv32i_word pc_2;


	 //wmask
	 logic [3:0] wmask_2;

	/* BR stall detection */
	logic br_detect;
//assigns
	assign br_detect = (br_2 | jmp_2) ^ (br_4 | jmp_4);

	assign dcache_wmask = wmask_2;
//modules
IF_ID IFID_latch (
    .clk(clk),
    .load(br_detect), /* Stall signal */
    .reset(reset),
    //inputs from stage 1
    .pcplus4_i(pc_alu_out_1),
    .pc_i(PC_out_1),
    .ir_i(icache_rdata),
    //outputs to stage 2
    .pcplus4_o(pc_plus4_2),
    .pc_o(pc_2),
    //outputs to stage 2 from IR
    .funct3_o(IR_funct3_2),
    .funct7_o(IR_funct7_2),
    .opcode_o(IR_opcode_2),
    .i_imm_o(IR_i_imm_2),
    .s_imm_o(IR_s_imm_2),
    .b_imm_o(IR_b_imm_2),
    .u_imm_o(IR_u_imm_2),
    .j_imm_o(IR_j_imm_2),
    .rs1_o(IR_rs1_2),
    .rs2_o(IR_rs2_2),
    .rd_o(rd_2)
);

regfile regfile(
	.clk(clk),
	.load(~st_5), /* Load on all instructions but stores */
	.in(wbmux_out_5),
	.src_a(IR_rs1_2),
	.src_b(IR_rs2_2),
	.dest(rd_5),
	.reg_a(rs1_2),
	.reg_b(rs2_2)
);



instruction_decode ID (
	/* INPUTS */
	.opcode(IR_opcode_2),
	.funct3(IR_funct3_2),
	.funct7(IR_funct7_2),
	/* OUTPUTS */
	.alu_src(alu_src_2),
	.alu_out_sel(alu_out_sel_2),
	.alu_op(alu_op_2),
	.jmp_sel(jmp_sel_2),
	.ld(ld_2),
	.st(st_2),
	.br(br_2),
	.jmp(jmp_2),
	.imm_sel(imm_sel_2),
	.wmask(wmask_2)
);

register #(1) STALL_ID_EX (
	.clk(clk),
	.load(1'b1),
	.in(br_detect),
	.out(/*STALL_EX_MEM*/)
);

/* MUXES */
always_comb
begin
	/* IMMEDIATE MUX */
	unique case (imm_sel_2)
		i_imm: imm_2 = IR_i_imm_2;
		j_imm: imm_2 = IR_j_imm_2;
		b_imm: imm_2 = IR_b_imm_2;
		s_imm: imm_2 = IR_s_imm_2;
		u_imm: imm_2 = IR_u_imm_2;
	endcase
end

//Stage 3: Execute
//logic declaration
rv32i_word pcplus4_3;
rv32i_word target_alu_pc_3;

rv32i_word target_alu_out_3;  //get this from target_alu module

rv32i_word ALU_rs1_3;
rv32i_word rs2_3; //goes to alu_mux_3, and stage 4
rv32i_word ALU_out_3; //

rv32i_word imm_3; //goes to alu_mux_3, and target_alu_3
rv32i_word alu_mux_out_3; //get this from alu_mux

logic alu_src_3;  //select bit for alu_mux_3
alu_ops alu_op_3; //select bit for ALU

logic jmp_sel_3;
logic ld_3;
logic st_3;
logic br_3;
logic jmp_3;
rv32i_reg rd_3;
//assigns

//modules
ID_EX IDEX_latch (
  .clk (clk),
  .load (/* need load signal */),
  .reset (reset),
  //inputs from stage 2
  .pcplus4_i (pc_plus4_2),
  .pc_i (pc_2),
  .rs1_i (rs1_2),
  .rs2_i (rs2_2),
  .imm_i (imm_2),
  .alu_src_i (alu_src_2),
  .alu_op_i (alu_op_2),
  .jmp_sel_i (jmp_sel_2),
  .ld_i (ld_2),
  .st_i (st_2),
  .br_i (br_2),
  .jmp_i (jmp_2),
  .rd_i (rd_2),
  //outputs to stage 3
  .pcplus4_o (pcplus4_3),
  .pc_o (target_alu_pc_3),
  .rs1_o (ALU_rs1_3),
  .rs2_o (rs2_3),
  .imm_o (imm_3),
  .alu_src_o (alu_src_3),
  .alu_op_o (alu_op_3),
  .jmp_sel_o (jmp_sel_3),
  .ld_o (ld_3),
  .st_o (st_3),
  .br_o (br_3),
  .jmp_o (jmp_3),
  .rd_o (rd_3)

);

alu target_alu_3(
  .aluop (alu_ops'(3'b000)),
  .a (target_alu_pc_3),
  .b (imm_3),
  .f (target_alu_out_3)
);

alu ALU(
  .aluop (alu_op_3)
  .a (ALU_rs1_3),
  .b (alu_mux_out_3),
  .f (ALU_out_3)
);
/* MUXES */
always_comb begin  //case statement for alumux
  unique case (alu_src_3)
    1'b0 : alu_mux_out_3 = rs2_3;
    1'b1 : alu_mux_out_3 = imm_3;
  endcase
end


//Stage 4: Mem
//logic declaration
	rv32i_word pc_plus4_4;
	rv32i_word br_out_4;
	rv32i_word rs2_4;
	rv32i_word alu_out_4;
	logic jmp_sel_4, ld_4, st_4; //br_4, jmp_4; declared earlier
	rv32i_reg rd_4;

  logic bralu_and_4;  //gate logics
  logic jmp_or_4;

  rv32i_word DCache_rdata_4;

  //rv32i_word brj_mux_out_4;	//declared earlier

  //magic mem logics
  logic magic_resp_4;
  logic [3:0] magic_wmask_4;
  //dummy signals for port a
  logic magic_resp_4_dead;
  logic [31:0] magic_rdata_4_dead

//assigns
//Might need to mask the alu_out_4 to 1 bit
assign bralu_and_4 = br_4 & alu_out_4[0];  //TODO double check this truncation

assign jmp_or_4 = jmp_4 | bralu_and_4;  //OR gate
//from Stage 1

assign pcmux_sel_1 = jmp_or_4;


/* DCACHE SIGNALS */
assign dcache_address = alu_out_4;
assign dcache_read = ld_4;
assign dcache_write = st_4;
assign dcache_wdata = rs2_4;


//modules
EX_MEM EXMEM_latch (
	.clk(clk),
	.load(/* STALL SIGNAL */),
	.reset(/* RESET SIGNAL */),
	/* INPUTS */
	.pcplus4_i(pcplus4_3),
	.br_out_i(target_alu_out_3),
	.rs2_i(rs2_3),
	.alu_out_i(ALU_out_3),
	.jmp_sel_i(jmp_sel_3),
	.ld_i(ld_3),
	.st_i(st_3),
	.br_i(br_3),
	.jmp_i(jmp_3),
	.rd_i(rd_3),
	/* OUTPUTS */
	.pcplus4_o(pc_plus4_4),
	.br_out_o(br_out_4),
	.rs2_o(rs2_4),
	.alu_out_o(alu_out_4),
	.jmp_sel_o(jmp_sel_4),
	.ld_o(ld_4),
	.st_o(st_4),
	.br_o(br_4),
	.jmp_o(jmp_4),
	.rd_o(rd_4)
);

always_comb begin
  unique case (jmp_sel_4)
    brj_mux::br_out : brj_mux_out_4 = br_out_4;
    brj_mux::jalr   : brj_mux_out_4 = alu_out_4;
  endcase
end

//Stage 5: Write Back
//logic declaration
	rv32i_word pc_plus4_5;
	rv32i_word rdata_5;
	rv32i_word alu_out_5;
	logic ld_5, jmp_5;
	//rv32i_reg rd_5;

  //rv32i_word wbmux_out_5;	/declarted these in stage dos

//assigns

//modules

always_comb begin
  unique case ({jmp_5, ld_5})
    wb_mux::alu_out : wbmux_out_5 = alu_out_5;
    wb_mux::rdata :   wbmux_out_5 = rdata_5;
    wb_mux::pcplus4 : wbmux_out_5 = pc_plus4_5;
    default: begin	//setting output due to "always_comb construct doesnt infer purely combo logic
	 wbmux_out_5 = alu_out_5;
	 `BAD_MUX_SEL;
	 end
  endcase
end

MEM_WB MEMWB_latch (
	.clk(clk),
	.load(/* STALL SIGNAL */),
	.reset(/* RESET SIGNAL */),
	.pcplus4_i(pc_plus4_4),
	.rdata_i(dcache_rdata),
	.alu_out_i(alu_out_4),
	.ld_i(ld_4),
	.st_i(st_4),
	.jmp_i(jmp_4),
	.rd_i(rd_4),

	.pcplus4_o(pc_plus4_5),
	.rdata_o(rdata_5),
	.alu_out_o(alu_out_5),
	.ld_o(ld_5),
	.st_o(st_5),
	.jmp_o(jmp_5),
	.rd_o(rd_5)
);



endmodule : cpu_datapath
