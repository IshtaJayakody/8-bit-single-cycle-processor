// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne

module data_memory_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;
    wire read , write , busywait;
    wire [7:0] address , readdata , writedata;

    reg [7:0] instr_mem [1024:0] ;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)

    always @(PC) begin
        #2
        INSTRUCTION[7:0]<=instr_mem[PC] ;
        INSTRUCTION[15:8]<=instr_mem[PC+31'd1] ;
        INSTRUCTION[23:16]<=instr_mem[PC+31'd2] ;
        INSTRUCTION[31:24]<=instr_mem[PC+31'd3] ;
    end



    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        //{instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        //{instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        //{instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC , INSTRUCTION , CLK ,RESET , read , write , busywait,address,readdata,writedata);
    data_memory my_data_memory(CLK , RESET , read , write , address , writedata , readdata , busywait);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("data_memory_wavedata.vcd");
		$dumpvars(0, data_memory_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;

        #1 RESET = 1'b1;
        #8 RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule