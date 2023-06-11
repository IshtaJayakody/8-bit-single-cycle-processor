/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

module instrcache(clk, reset, busywait, address, readdata, mem_busywait, mem_address, mem_readdata, mem_read);

    input clk, reset; // Initially clock and reset is defined as inputs
    output reg busywait; // then Busywait signal is defined as output reg 
    input [9:0] address; // address is a 10 bit input
    output reg [31:0] readdata; // readdata refers to the instruction which is read from the cache memory
    input mem_busywait; // mem_busywait is a input whicg generates by instruction memory
    output reg [5:0] mem_address; // mem_address is defined as a 6 bit output from instruction cache
    input [127:0] mem_readdata; // Then 128 bits are allocated for mem_readdata
    output reg mem_read; // mem_read signal is the output which is controlling the Instruction memory. So it define as output reg type 

    wire [2:0] index;  // tag and index are 3-bit wires
    wire [2:0] tag;
    wire valid_bit, hit; // Then hit and valid_bit ara defined as wires
    reg [31:0] word_selector; // This word_selector is use for read instruction according to the offset of the Pc address
    reg [131:0] cacheMem_array [7:0]; // Finally here we are defining 8 memory blocks in the instruction cache memory 

   
    // Initially, after arriving a new address to the memory dirty bit, valid_bit, index and tag are extracted after 1 time unit delay
    assign #1 index = address[6:4];
    assign #1 valid_bit =  cacheMem_array[address[6:4]][131];
    assign #1 tag = cacheMem_array[address[6:4]][130:128];

    // Then hit signal is generated considering valid bit, tag of the existing meory block and tag part of the address.
    //This takes 0.9 time unit delay
    assign #0.9 hit = ((tag == address[9:7])&& valid_bit) ? 1'b1 : 1'b0;
    
    // This always block is used to output the data which a stored in cache to the register file
    // Always block is sensitive to address, hit, read and write
    always @ (address, /*hit*/cacheMem_array[address[6:4]])
    begin
        // If there is a read and a hit, initially word selecter is updated in 1 time unit according to the offset
        case (address[3:2])
            2'b00: #1 word_selector = cacheMem_array[address[6:4]][31:0];
            2'b01: #1 word_selector = cacheMem_array[address[6:4]][63:32];
            2'b10: #1 word_selector = cacheMem_array[address[6:4]][95:64];
            2'b11: #1 word_selector = cacheMem_array[address[6:4]][127:96];
        endcase
        // Then assign that value to readdata
        readdata = word_selector;
    end

    /*always @ (hit)
    begin
        readdata = word_selector;
    end*/

    // This always block is used to update cache from the data memory
    // always block is sensitive to mem_read
    always @ (mem_read)
    begin
        // If mem_read equals to zero followig set of code will be triggered after 1 time unit delay
        if(mem_read == 0)
        begin
            #1
            cacheMem_array[address[6:4]][131] = 1; // then valid bit is set as 1
            cacheMem_array[address[6:4]][130:128] = address[9:7]; // then the tag part of the cache memory block is set 
            cacheMem_array[address[6:4]][127:0] = mem_readdata;// finally read data from memory will assign to the correspondig cache memory block
        end
    end


    /* Cache Controller FSM Start */

    parameter IDLE = 1'b0, MEM_READ = 1'b1;
    reg state, next_state;

    // Here is combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                // In the ideal state if there is a read or write operation and dirty bit and hit equals to zero 
                //next state is assigned as MEM_READ
                if (!hit)  
                    next_state = MEM_READ;
                // Otherwise it remains in ideal state
                else
                    next_state = IDLE;
            
            MEM_READ:
                // In the memory reading state if mem_busywait signal is 0, next state is assigned as ideal
                if (!mem_busywait)
                    next_state = IDLE;
                // Otherwise it remains in memory reading state 
                else    
                    next_state = MEM_READ;
        endcase
    end

     // Here is the combinational output logic
    // This always block is triggered to all the changes in the cache while simulating
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_address = 8'dx;
                if(!hit) // if there is a read or write opearation and there is miss busywait is assigned as 1
                    busywait = 1;
                else
                    busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_address = {address[9:7], index};
                busywait = 1;
            end
        endcase
    end

 // Here is sequential logic for state transitioning and reset the cache memory
    integer i; 
    always @(posedge clk, reset)
    begin
        // If reset signal is high, state is initialized to the ideal state. And all the cache memory data is cleared
        if(reset)
        begin
            state = IDLE;
            for (i=0;i<8; i=i+1)
            begin
            cacheMem_array[i][131] = 0;
            end
        end
        else
        // Otherwise circuit will be moved to next state.
        begin
            state = next_state;
        end
    end

    /* Cache Controller FSM End */
endmodule
