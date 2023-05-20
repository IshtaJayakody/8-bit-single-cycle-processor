//TESTING
module stimulus();

reg [0:7] R1 ,R2;
wire [0:7] Rout ;
reg [0:2] select;

//DATA1 , DATA2 , RESULT , SELECT
ALU alu(R1,R2,Rout,select);

initial
begin
    $monitor ($time," select = %b  R1 = %b  R2=%b  Rout = %b",select ,R1 ,R2, Rout);
    $dumpfile("wavedata11.vcd");
    $dumpvars(0,alu);

    #2 select <= 3'b000 ; R1 <= 8'b00000010; R2 <= 8'b00000001;
    
    #16 $finish;

end
always #2 select = select+1 ;

endmodule

module ALU(DATA1,DATA2,RESULT,SELECT);

input wire[7:0] DATA1,DATA2; // Declaring an input wire-buses DATA1 and DATA2
input wire[2:0] SELECT; // Declaring an input wire-buse SELECT
output reg[7:0] RESULT; // Declaring an output RESULT as a reg
wire [7:0] FORWARD_wire,ADD_wire,AND_wire,OR_wire; // Declaring wires which connects the multiplexer and Circuits which implement FORWARD,AND,ADD,OR operations


forward f1(DATA2,FORWARD_wire); //Creating an instance of forward module
adder f2(DATA1,DATA2,ADD_wire); //Creating an instance of adder module
AND f3(DATA1,DATA2,AND_wire); //Creating an instance of AND module
OR f4(DATA1,DATA2,OR_wire); //Creating an instance of OR module

//Implementing a multiplexer to select the algrebric operation we need according to SELECT signal
always @(DATA1 or DATA2 or SELECT) begin
    
     case (SELECT)
         3'b000: assign RESULT = FORWARD_wire;
         3'b001: assign RESULT = ADD_wire;
         3'b010: assign RESULT = AND_wire;
         3'b011: assign RESULT = OR_wire;
         default: assign RESULT = 8'bxxxxxxxx; //If SELECT is neither 000,001,010,011, operations to other codes are not assigned yet. Hence Unknown result is generated.
     endcase
end
endmodule

//Module which implemented ADD operation
module adder(DATA1,DATA2,RESULT);
    input wire[7:0] DATA1,DATA2;
    output wire[7:0] RESULT;

    assign #2 RESULT = DATA1+DATA2; //Adding DATA1 and DATA2 inputs with a delay
endmodule

//Module which implemented FORWARD operation
module forward(DATA2,RESULT);
    input wire[7:0] DATA2;
    output wire[7:0] RESULT;

    assign #1 RESULT = DATA2; //Assigning DATA2 to RESULT
endmodule

//Module which implemented AND operation
module AND (DATA1,DATA2,RESULT);
    input wire[7:0] DATA1,DATA2;
    output wire[7:0] RESULT;
    
    assign #1 RESULT = DATA1 & DATA2; //AND DATA1 and DATA2 inputs with a delay
endmodule

//Module which implemented OR operation
module OR (DATA1,DATA2,RESULT);
    input wire[7:0] DATA1,DATA2;
    output wire[7:0] RESULT;
    
    assign #1 RESULT = DATA1 | DATA2; //OR DATA1 and DATA2 inputs with a delay
endmodule