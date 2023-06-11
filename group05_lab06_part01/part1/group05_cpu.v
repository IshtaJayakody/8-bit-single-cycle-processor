//module for the cpu
module cpu(PC , INSTRUCTION , CLK ,RESET , read , write , busywait,address,read_data,write_data) ;
    //declare inputs and outputs 
    input CLK, RESET , busywait;
    input wire [7:0] read_data;
    output [31:0] PC;
    output read , write ;
    output [7:0] address , write_data ;
    input wire [31:0] INSTRUCTION;

    //declare respective wires

    wire [2:0] READREG1 , READREG2 , WRITEREG ;
    wire [7:0] OPCODE , IMMEDIATE , offset;
    
    wire [2:0] ALUOP , PC_select;
    wire MUX1_select , MUX2_select , MUX3_select , WRITEENABLE ,ZERO  ;

    wire [7:0] ALURESULT , REGOUT1 , REGOUT2 ;
    
    wire [7:0] REGOUT2_2scomp ;

    wire [7:0] mux1_OUTPUT , mux2_OUTPUT , mux3_OUTPUT ;

    wire [31:0] PC_val , PC_target , PC_next;

    //assign the value of alu result to the address and write data to the regout 1
    assign address[7:0] = ALURESULT[7:0] ;
    assign write_data[7:0] = REGOUT1[7:0] ;

    //break the instruction to resoective parts and assign for the wires 
    assign READREG2[2:0] = INSTRUCTION[2:0] ;
    assign READREG1[2:0] = INSTRUCTION[10:8] ;
    assign WRITEREG[2:0] = INSTRUCTION[18:16] ;
    assign OPCODE[7:0] = INSTRUCTION[31:24] ;
    assign IMMEDIATE[7:0] = INSTRUCTION[7:0] ;
    assign offset[7:0] = INSTRUCTION[23:16] ;


    //call the respective modules and instantiate respective modules
    pc myPC(CLK , RESET , PC , PC_next);
    Control_Unit my_Control_Unit(OPCODE , WRITEENABLE , ALUOP , MUX1_select , MUX2_select , MUX3_select , PC_select,ALUShift,read,write,busywait);
    reg_file my_reg(mux3_OUTPUT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    TWOS_Comp my_TWOS_Comp(REGOUT2 , REGOUT2_2scomp);
    MUX_7x2x1 my_mux1(REGOUT2 , REGOUT2_2scomp , mux1_OUTPUT , MUX1_select);
    MUX_7x2x1 my_mux2(IMMEDIATE , mux1_OUTPUT , mux2_OUTPUT , MUX2_select);
    MUX_7x2x1 my_mux3(read_data , ALURESULT , mux3_OUTPUT , MUX3_select);
    ALU my_ALU(REGOUT1,mux2_OUTPUT,ALURESULT,ALUOP,ZERO,ALUShift);
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
module Control_Unit (OPCODE , WRITEENABLE , ALUOP , MUX1_select , MUX2_select , MUX3_select ,PC_select,ALUShift,read,write,busywait );
    input [7:0]OPCODE ;
    input busywait ;
    output reg [2:0] ALUOP , PC_select ;
    output reg MUX1_select , MUX2_select , MUX3_select , WRITEENABLE ,ALUShift ,read , write;
    //MUX1_select ----------to select 2s compliment
    //MUX2_select ----------to select immediate value or register value
    //MUX3_select ----------to select the data from memory output(1) or ALU output(0)

    always @(OPCODE,busywait) begin //selecting respective selecting signals

        case(OPCODE) 
                8'b00000000: begin //loadi
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b000 ; 
                    //MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b1 ;
                    MUX3_select <= 1'b0 ; 
                    PC_select <= 3'b000 ;
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;

                
                    end

                8'b00000001: begin //mov
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b000 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ; 
                    MUX3_select <= 1'b0 ;
                    PC_select <= 3'b000 ;
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;

                    end

                8'b00000010: begin //add
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    MUX3_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;

                    end

                8'b00000011: begin //sub
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b0 ; 
                    MUX2_select <= 1'b0 ;
                    MUX3_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                    
                    end

                8'b00000100: begin //and
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b010 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    MUX3_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                  
                    end

                8'b00000101: begin //or
                    #1 
                    WRITEENABLE <= 1'b1; 
                    ALUOP <= 3'b011 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    MUX3_select <= 1'b0 ;
                    PC_select <= 3'b000 ; 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                    
                    end

                8'b00000110: begin // j
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b001 ; 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                  
                    end

                8'b00000111: begin // beq
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b010 ; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b0 ; 
                    MUX2_select <= 1'b0 ;
                    //dont need to add mux3 select
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                end

                8'b00001100: begin // bne
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b011 ; 
                    ALUOP <= 3'b001 ; 
                    MUX1_select <= 1'b0 ; 
                    MUX2_select <= 1'b0 ;
                    //dont need yo add mux 3 select
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                    end

                8'b00001101: begin //sll logical shift to left 
                    #1
                    WRITEENABLE <= 1'b1; 
                    PC_select <= 3'b000 ; 
                    ALUOP <= 3'b100 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b1 ;
                    //dont need to add mux 3 select
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b0 ;
                end

                8'b00001110: begin //srl logical shift to right
                    #1
                    WRITEENABLE <= 1'b1; 
                    PC_select <= 3'b000 ; 
                    ALUOP <= 3'b100 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b1 ;
                    //dont need to add mux 3 select 
                    ALUShift <= 1'b1;
                    read <= 1'b0;
                    write <= 1'b0 ;
                end

                8'b00001000: begin //lwd load the value from the data memory relevent to the address in the respective register to the destination register
                    #1 
                    ALUOP <= 3'b000 ; 
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    MUX3_select <= 1'b1 ;
                    ALUShift <= 1'b0;
                    read <= 1'b1;
                    write <= 1'b0 ;

                    if (busywait == 1'b1) begin 
                        PC_select <= 3'b100 ; //to stop the pc at given value
                        WRITEENABLE <= 1'b0;  //to disable the writing to the registers while busywait =1
                    end else if (busywait == 1'b0) begin
                        PC_select <= 3'b000 ;
                        WRITEENABLE <= 1'b1; 
                    end
                end

                8'b00001001: begin //lwi load the value from the data memory relevent to the address in the respective immidiate value to the destination register
                    #1
                    ALUOP <= 3'b000 ; 
                    //MUX1_select <= 1'b1 ; //because loading immidiate 
                    MUX2_select <= 1'b1 ;
                    MUX3_select <= 1'b1 ;
                    ALUShift <= 1'b0;
                    read <= 1'b1;
                    write <= 1'b0 ;

                    if (busywait == 1'b1) begin 
                        PC_select <= 3'b100 ; //to stop the pc at given value
                        WRITEENABLE <= 1'b0;  //to disable the writing to the registers while busywait =1
                    end else if (busywait == 1'b0) begin
                        PC_select <= 3'b000 ;
                        WRITEENABLE <= 1'b1; 
                    end
                end

                8'b00001010: begin //swd write value from Rt to the memory address given in Rs.no register writing happens          
                    #1
                    ALUOP <= 3'b000 ;
                    MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b0 ;
                    //dont need to add mux 3 select 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b1 ;
                    WRITEENABLE <= 1'b0;  //no register writing happens

                    if (busywait == 1'b1) begin 
                        PC_select <= 3'b100 ; //to stop the pc at given value
                    end else if (busywait == 1'b0) begin
                        PC_select <= 3'b000 ;
                    end
                end


                8'b00001011: begin //swi write value from Rt to the memory address given as an Immidiate value.no register writing happens          
                    #1
                    ALUOP <= 3'b000 ;
                    //MUX1_select <= 1'b1 ; 
                    MUX2_select <= 1'b1 ;
                    //dont need to add mux 3 select 
                    ALUShift <= 1'b0;
                    read <= 1'b0;
                    write <= 1'b1 ;
                    WRITEENABLE <= 1'b0;  //no register writing happens

                    if (busywait == 1'b1) begin 
                        PC_select <= 3'b100 ; //to stop the pc at given value
                    end else if (busywait == 1'b0) begin
                        PC_select <= 3'b000 ;
                    end
                end


                default: begin
                    #1 
                    WRITEENABLE <= 1'b0; 
                    PC_select <= 3'b000 ;
                    ALUShift <= 1'b0; 
                    read <= 1'b0;
                    write <= 1'b0 ;
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
        if(PC_select==3'b001)begin // j
            PC_next = PC_target ;
        end else if (PC_select==3'b010 && ZERO==1'b1) begin //beq 
            PC_next = PC_target;
        end else if (PC_select==3'b011 && ZERO==1'b0) begin //bne 
            PC_next = PC_target;
        end else if (PC_select == 3'b100) begin //lwd , lwi , swd ,swi
            PC_next = PC_val + 32'b11111111111111111111111111111100; //substract 4 from the PC_val to pause the pc val
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


