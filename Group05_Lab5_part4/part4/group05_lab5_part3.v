//module for the cpu
module cpu(PC , INSTRUCTION , CLK ,RESET) ;
    //declare inputs and outputs 
    input CLK, RESET;
    output [31:0] PC;
    input wire [31:0] INSTRUCTION;

    //declare respective wires

    wire [2:0] READREG1 , READREG2 , WRITEREG ;
    wire [7:0] OPCODE , IMMEDIATE , offset;
    
    wire [2:0] ALUOP , PC_select;
    wire MUX1_select , MUX2_select , WRITEENABLE ,ZERO  ;

    wire [7:0] ALURESULT , REGOUT1 , REGOUT2 ;
    
    wire [7:0] REGOUT2_2scomp ;

    wire [7:0] mux1_OUTPUT ;

    wire [7:0] mux2_OUTPUT ;

    wire [31:0] PC_val , PC_target , PC_next;

    //break the instruction to resoective parts and assign for the wires 
    assign READREG2[2:0] = INSTRUCTION[2:0] ;
    assign READREG1[2:0] = INSTRUCTION[10:8] ;
    assign WRITEREG[2:0] = INSTRUCTION[18:16] ;
    assign OPCODE[7:0] = INSTRUCTION[31:24] ;
    assign IMMEDIATE[7:0] = INSTRUCTION[7:0] ;
    assign offset[7:0] = INSTRUCTION[23:16] ;


    //call the respective modules and instantiate respective modules
    pc myPC(CLK , RESET , PC , PC_next);
    Control_Unit my_Control_Unit(OPCODE , WRITEENABLE , ALUOP , MUX1_select , MUX2_select ,PC_select);
    reg_file my_reg(ALURESULT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    TWOS_Comp my_TWOS_Comp(REGOUT2 , REGOUT2_2scomp);
    MUX_7x2x1 my_mux1(REGOUT2 , REGOUT2_2scomp , mux1_OUTPUT , MUX1_select);
    MUX_7x2x1 my_mux2(IMMEDIATE , mux1_OUTPUT , mux2_OUTPUT , MUX2_select);
    ALU my_ALU(REGOUT1,mux2_OUTPUT,ALURESULT,ALUOP,ZERO);
    PC_getTarget my_PC_getTarget(PC ,PC_val , offset ,PC_target ) ;
    PC_next_select my_PC_next_select(PC_select , ZERO , PC_next , PC_val , PC_target);

endmodule

//module for the program counter
module pc (CLK , RESET , PC  ,PC_next);
    input CLK ,RESET;
    output reg[31:0] PC ;
    input [31: 0] PC_next ; // gives the next PC value


    always @(posedge CLK) begin
        if ( RESET == 1'b1 ) begin
            #1 PC = 32'b00000000000000000000000000000000;
        end else  begin
            #1 PC = PC_next ;
        end  
        
    end

    
endmodule


//module for the control unit
module Control_Unit (OPCODE , WRITEENABLE , ALUOP , MUX1_select , MUX2_select ,PC_select );
    input [7:0]OPCODE ;
    output reg [2:0] ALUOP , PC_select ;
    output reg MUX1_select , MUX2_select , WRITEENABLE  ;


    always @(OPCODE) begin //selecting respective selecting signals

        case(OPCODE) 
                8'b00000000: begin //loadi
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b000 ; 
                    //MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b1 ; 
                    PC_select <= 3'b000 ;
                
                    end

                8'b00000001: begin //mov
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b000 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ; 
                    PC_select <= 3'b000 ;
                   
                    end

                8'b00000010: begin //add
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                  
                    end

                8'b00000011: begin //sub
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b0 ; 
                    MUX2_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                    
                    end

                8'b00000100: begin //and
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b010 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                  
                    end

                8'b00000101: begin //or
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b011 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                    
                    end

                8'b00000110: begin // j
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b001 ; 
                  
                    end

                8'b00000111: begin // beq
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b010 ; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b0 ; 
                    MUX2_select <= 1'b0 ;
                   

                    end

                default: begin
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b000 ; 
                    
                end
                
        endcase
    end

endmodule

//module for the 2s complement
module TWOS_Comp (REGOUT2 , REGOUT2_2scomp);
    input [7:0] REGOUT2 ;
    output [7:0] REGOUT2_2scomp ;

    assign #1  REGOUT2_2scomp = ~REGOUT2 + 8'b00000001  ;

endmodule



//module for the mux
module MUX_7x2x1 (INPUT1 , INPUT2 , OUTPUT , SELECT);
    input [7:0] INPUT1 , INPUT2 ;
    input SELECT ;
    output reg [7:0] OUTPUT ;

    always @(INPUT1 , INPUT2,SELECT) begin
        if(SELECT==1'b1)begin
            assign OUTPUT = INPUT1;
        end else if (SELECT==1'b0) begin
            assign OUTPUT = INPUT2;
        end
    end

endmodule


//module for next PC value
module PC_next_select(PC_select , ZERO , PC_next , PC_val , PC_target);
    input [31:0] PC_val , PC_target ;
    input [2:0] PC_select ;
    input ZERO ;
    output reg [31:0] PC_next ;

    always @(PC_select , ZERO , PC_val , PC_target) begin
        if(PC_select==3'b001)begin
            PC_next = PC_target ;
        end else if (PC_select==3'b010 && ZERO==1'b1) begin
            PC_next = PC_target;
        end else begin
            PC_next = PC_val;
        end
    end

endmodule

// module for the branch and the jump
module PC_getTarget(PC ,PC_val , offset ,PC_target ) ; //offset is from instruction
    output reg [31:0] PC_val ;
    input [7:0] offset ;
    input [31:0] PC ;
    output reg [31:0] PC_target ;
    reg [31:0] temp;
    
    always @(offset , PC_val) begin
        if(offset[7] == 1'b0) begin
            temp[31:10] <= 22'b0000000000000000000000 ;
            temp[9:2] <= offset[7:0] ;
            temp[1:0] <= 2'b00 ;
        end else if (offset[7] == 1'b1) begin
            temp[31:10] <= 22'b1111111111111111111111 ;
            temp[9:2] <= offset[7:0] ;
            temp[1:0] <= 2'b00 ;
        end
    end 

    always @(temp) begin
        #2 PC_target = PC_val + temp ;
    end

    always @(PC) begin
        #1 PC_val = PC + 32'd4 ;
    end

endmodule 




// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne


module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;
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
        $readmemb("instr_mem.mem", instr_mem,0,256);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);
    

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        //RESET = 1'b0;

        RESET = 1'b1;
        #10 RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule