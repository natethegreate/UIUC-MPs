import types::*;
//import mux_types::*;

module mp3(
  input clk,
  input  logic icache_resp,
  input  logic [31:0] icache_rdata,
  output logic icache_read,
  output logic [31:0] icache_address,

  input  logic dcache_resp,
  input  logic [31:0] dcache_rdata,
  output logic dcache_read, dcache_write,
  output logic [3:0] dcache_wmask,
  output logic [31:0] dcache_wdata,
  output logic [31:0] dcache_address
);

/************ Signals Needed for RVFI Monitor ************/
logic load_pc;
logic load_regfile;
/*********************************************************/

logic reset;

//dummy signals for magic memory
logic magic_resp_1_dead;
logic magic_rdata_1_dead;
logic magic_resp_4_dead;
logic magic_rdata_4_dead;

//Magic memory logics, Icache
/*
logic icache_resp;
logic [31:0] icache_rdata;
logic icache_read;
logic [31:0] icache_address;
*/
/* DCACHE INTERFACE */
/*
logic dcache_resp;
logic [31:0] dcache_rdata;
logic dcache_read;
logic dcache_write;
logic [3:0] dcache_wmask;
logic [31:0] dcache_wdata;
logic [31:0] dcache_address;
*/
cpu_datapath cpu(.*);

//Caches


//magic_memory_dp ICache(
//  //Port A
//  .clk(clk),
//  .read_a(icache_read),
//  .address_a (icache_address),
//  .resp_a(icache_resp),
//  .rdata_a(icache_rdata),
//  //Port B
//  .read_b (dcache_resp),
//  .write(dcache_write),
//  .wmask (dcache_wmask),
//  .address_b (dcache_address),
//  .wdata (dcache_wdata),
//  .resp_b(dcache_resp),
//  .rdata_b (dcache_rdata)
//);


endmodule : mp3
