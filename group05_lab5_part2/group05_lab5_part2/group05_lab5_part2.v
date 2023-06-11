// Computer Architecture (CO224) - Lab 05
// Design: Register File of Simple Processor
// Author: Kisaru Liyanage
// Group 05 Authors Gunarathna H.P.H.M(E/18/118), Jayakody J.M.I.H(E/18/149)

//Testbench
module reg_file_tb;
    
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
       
    initial
    begin
        CLK = 1'b1;
        
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("reg_file_wavedata.vcd");
		$dumpvars(0, reg_file_tb);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #4
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #6
        RESET = 1'b0;
        
        #2
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #7
        WRITEENABLE = 1'b0;
        
        #1
        READREG1 = 3'd2;
        
        #7
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #8
        WRITEENABLE = 1'b0;
        
        #8
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #8
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = -3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule


module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
    input[7:0] IN; // Declaring an input wire-bus to take WRITEDATA signals
    input[2:0] OUT1ADDRESS,OUT2ADDRESS,INADDRESS; // Declaring an input wire-bus to take WRITEDATA signals
    input CLK,WRITE,RESET; // Declaring clock pulse wire, WRITE_ENABLE wire and RESET wire as input 
    output reg [7:0] OUT1,OUT2;  // Declaring REGOUT1 and REGOUT2 signals as register outputs
    reg[7:0] register[0:7]; // Declaring register0-register7 as an array of words 

    //For rising edges of clock pulse
    always @(posedge CLK) begin
        if(RESET==1)begin //When RESET = 1 clearing registers with a delay

            #1
             register[0]<=0;
             register[1]<=0;
             register[2]<=0;
             register[3]<=0;
             register[4]<=0;
             register[5]<=0;
             register[6]<=0;
             register[7]<=0;
        end
        else if(WRITE==1)begin // When WRITE_ENABLE = 1 writing to a specific register
            
            case(INADDRESS) //Choosing the register to be written by considering the INADDRESS signal
                3'b000:#1 register[0] <= IN;
                3'b001:#1 register[1] <= IN;
                3'b010:#1 register[2] <= IN;
                3'b011:#1 register[3] <= IN;
                3'b100:#1 register[4] <= IN;
                3'b101:#1 register[5] <= IN;
                3'b110:#1 register[6] <= IN;
                3'b111:#1 register[7] <= IN;
                default:;
            endcase
        end
        
    end

    //When changes occur in registers register0-register7 or OUT1ADDRESS, asynchrous reading operating takes place.
    always @(OUT1ADDRESS,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7]) begin
        case (OUT1ADDRESS) //Choosing the register to be read by considering the OUT1ADDRESS signal
            3'b000:#2 OUT1 = register[0];
            3'b001:#2 OUT1 = register[1];
            3'b010:#2 OUT1 = register[2];
            3'b011:#2 OUT1 = register[3];
            3'b100:#2 OUT1 = register[4];
            3'b101:#2 OUT1 = register[5];
            3'b110:#2 OUT1 = register[6];
            3'b111:#2 OUT1 = register[7]; 
            default:; 
        endcase
    end

    //When changes occur in registers register0-register7 or OUT2ADDRESS, asynchrous reading operating takes place.
    always @(OUT2ADDRESS,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7]) begin
        case (OUT2ADDRESS) //Choosing the register to be read by considering the OUT2ADDRESS signal
            3'b000:#2 OUT2 = register[0];
            3'b001:#2 OUT2 = register[1];
            3'b010:#2 OUT2 = register[2];
            3'b011:#2 OUT2 = register[3];
            3'b100:#2 OUT2 = register[4];
            3'b101:#2 OUT2 = register[5];
            3'b110:#2 OUT2 = register[6];
            3'b111:#2 OUT2 = register[7]; 
            default:; 
        endcase      
    end

endmodule