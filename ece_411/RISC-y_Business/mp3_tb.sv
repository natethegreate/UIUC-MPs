module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic commit;
assign commit = dut.cpu.load_pc;
logic [63:0] order;
initial order = 0;
tb_itf itf();
always @(posedge itf.clk iff commit) order <= order + 1;
int timeout = 100000000;   // Feel Free to adjust the timeout value
assign itf.registers = dut.cpu.regfile.data;
assign itf.halt = dut.cpu.load_pc &
                  (dut.cpu.PC_out_1 == dut.cpu.pcmux_out_1); //removed datapath from the hierarchy

/************************* Error Halting Conditions **************************/
// Stop simulation on error detection
always @(itf.errcode iff (itf.errcode != 0)) begin
    repeat (30) @(posedge itf.clk);
    $display("TOP: Halting on Non-Zero Errorcode");
    $finish;
end

// Stop simulation on timeout (stall detection), halt
always @(posedge itf.clk) begin
    if (itf.halt)
        $finish;
    if (timeout == 0) begin
        $display("TOP: Timed out");
        $finish;
    end
    timeout <= timeout - 1;
end

// Simulataneous Memory Read and Write
always @(posedge itf.clk iff (itf.mem_read && itf.mem_write))
    $error("@%0t TOP: Simultaneous memory read and write detected", $time);

/* ICACHE INTERFACE */
logic icache_resp;
logic [31:0] icache_rdata;
logic icache_read;
logic [31:0] icache_address;
/* DCACHE INTERFACE */
logic dcache_resp;
logic [31:0] dcache_rdata;
logic dcache_read;
logic dcache_write;
logic [3:0] dcache_wmask;
logic [31:0] dcache_wdata;
logic [31:0] dcache_address;

mp3 dut(
	.clk	(itf.clk & ~itf.mon_rst),
	.*
);

magic_memory_dp memory(
	.clk	    (itf.clk),
	.read_a     (icache_read),
	.address_a  (icache_address),
	.resp_a		(icache_resp),
	.rdata_a	(icache_rdata),
	.read_b		(dcache_resp),
	.write		(dcache_write),
	.wmask		(dcache_wmask),
	.address_b	(dcache_address),
	.wdata		(dcache_wdata),
	.resp_b		(dcache_resp),
	.rdata_b	(dcache_rdata)
);

endmodule : mp3_tb
