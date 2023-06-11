module ALU(DATA1,DATA2,RESULT,SELECT,ZERO,ALUShift);

input wire[7:0] DATA1,DATA2; // Declaring an input wire-buses DATA1 and DATA2
input wire[2:0] SELECT; // Declaring an input wire-buse SELECT
input wire ALUShift ; //To select from shift operations
output [7:0] RESULT; // Declaring an Resultput RESULT as a reg
wire [7:0] FORWARD_wire,ADD_wire,AND_wire,OR_wire,Sll_wire,sra_wire; // Declaring wires which connects the multiplexer and Circuits which implement FORWARD,AND,ADD,OR operations
output reg ZERO ;

forward f1(DATA2,FORWARD_wire); //Creating an instance of forward module
adder f2(DATA1,DATA2,ADD_wire); //Creating an instance of adder module
AND f3(DATA1,DATA2,AND_wire); //Creating an instance of AND module
OR f4(DATA1,DATA2,OR_wire); //Creating an instance of OR module
logical_shifter_8bit f5(DATA1,DATA2,ALUShift,Sll_wire); //Creating an instance of shift module
//rotation f6(DATA1,DATA2,ALUShift,Sll_wire); //Creating an instance of rotation module

//Implementing a multiplexer to select the algrebric operation we need according to SELECT signal
// always @(DATA1 or DATA2 or SELECT) begin
    
//-----------------------------
    assign RESULT = (SELECT == 3'b000 ) ? FORWARD_wire : 
                    (SELECT == 3'b001) ? ADD_wire :
                    (SELECT == 3'b010) ? AND_wire :
                    (SELECT == 3'b011) ? OR_wire :
                    (SELECT == 3'b100) ? Sll_wire :
                    8'b0000_0000;


//-----------------------------

always @(RESULT) begin
    if (RESULT == 8'b00000000) begin
        ZERO  = 1'b1 ;
     end else begin
        ZERO = 1'b0 ;
     end    
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


module mux2X1( DATA1,DATA2,Selection,Result);
    input DATA1,DATA2;
    input Selection;
    output Result;
    wire DATA1_wire,Select_negate,DATA2_wire;
    and(DATA2_wire,DATA2,Selection);
    not(Select_negate,Selection);
    and(DATA1_wire,DATA1,Select_negate);
    or(Result,DATA1_wire,DATA2_wire);

endmodule


module logical_shifter_8bit (In, Shift_Amount, SelectOP, allResult);
  input SelectOP;
  input  [7:0] In;
  input [7:0] Shift_Amount;
  output reg [7:0] allResult;
  wire [7:0] OPsrl1,OPsrl2,OPsll1,OPsll2,Result;
  wire [7:0] srl_wire,sll_wire;
 
     always@(Result)begin
         #1 allResult = Result;
     end
    
    //4bit shift right
    mux2X1  srl_17 (In[7],1'b0,Shift_Amount[2],OPsrl1[7]);
    mux2X1  srl_16 (In[6],1'b0,Shift_Amount[2],OPsrl1[6]);
    mux2X1  srl_15 (In[5],1'b0,Shift_Amount[2],OPsrl1[5]);
    mux2X1  srl_14 (In[4],1'b0,Shift_Amount[2],OPsrl1[4]);
    mux2X1  srl_13 (In[3],In[7],Shift_Amount[2],OPsrl1[3]);
    mux2X1  srl_12 (In[2],In[6],Shift_Amount[2],OPsrl1[2]);
    mux2X1  srl_11 (In[1],In[5],Shift_Amount[2],OPsrl1[1]);
    mux2X1  srl_10 (In[0],In[4],Shift_Amount[2],OPsrl1[0]);
    
    //2 bit shift right
    
    mux2X1  srl_27 (OPsrl1[7],1'b0,Shift_Amount[1],OPsrl2[7]);
    mux2X1  srl_26 (OPsrl1[6],1'b0,Shift_Amount[1],OPsrl2[6]);
    mux2X1  srl_25 (OPsrl1[5],OPsrl1[7],Shift_Amount[1],OPsrl2[5]);
    mux2X1  srl_24 (OPsrl1[4],OPsrl1[6],Shift_Amount[1],OPsrl2[4]);
    mux2X1  srl_23 (OPsrl1[3],OPsrl1[5],Shift_Amount[1],OPsrl2[3]);
    mux2X1  srl_22 (OPsrl1[2],OPsrl1[4],Shift_Amount[1],OPsrl2[2]);
    mux2X1  srl_21 (OPsrl1[1],OPsrl1[3],Shift_Amount[1],OPsrl2[1]);
    mux2X1  srl_20 (OPsrl1[0],OPsrl1[2],Shift_Amount[1],OPsrl2[0]);
    
    //1 bit shift right
    mux2X1  srl_07 (OPsrl2[7],1'b0,Shift_Amount[0],srl_wire[7]);
    mux2X1  srl_06 (OPsrl2[6],OPsrl2[7],Shift_Amount[0],srl_wire[6]);
    mux2X1  srl_05 (OPsrl2[5],OPsrl2[6],Shift_Amount[0],srl_wire[5]);
    mux2X1  srl_04 (OPsrl2[4],OPsrl2[5],Shift_Amount[0],srl_wire[4]);
    mux2X1  srl_03 (OPsrl2[3],OPsrl2[4],Shift_Amount[0],srl_wire[3]);
    mux2X1  srl_02 (OPsrl2[2],OPsrl2[3],Shift_Amount[0],srl_wire[2]);
    mux2X1  srl_01 (OPsrl2[1],OPsrl2[2],Shift_Amount[0],srl_wire[1]);
    mux2X1  srl_00 (OPsrl2[0],OPsrl2[1],Shift_Amount[0],srl_wire[0]);

//-----------------------------------------------------------------------------------------------------

    //4bit shift left
    mux2X1  sll_17 (In[7],In[3],Shift_Amount[2],OPsll1[7]);
    mux2X1  sll_16 (In[6],In[2],Shift_Amount[2],OPsll1[6]);
    mux2X1  sll_15 (In[5],In[1],Shift_Amount[2],OPsll1[5]);
    mux2X1  sll_14 (In[4],In[0],Shift_Amount[2],OPsll1[4]);
    mux2X1  sll_13 (In[3],1'b0,Shift_Amount[2],OPsll1[3]);
    mux2X1  sll_12 (In[2],1'b0,Shift_Amount[2],OPsll1[2]);
    mux2X1  sll_11 (In[1],1'b0,Shift_Amount[2],OPsll1[1]);
    mux2X1  sll_10 (In[0],1'b0,Shift_Amount[2],OPsll1[0]);
    
    //2 bit shift left
    
    mux2X1  sll_27 (OPsll1[7],OPsll1[5],Shift_Amount[1],OPsll2[7]);
    mux2X1  sll_26 (OPsll1[6],OPsll1[4],Shift_Amount[1],OPsll2[6]);
    mux2X1  sll_25 (OPsll1[5],OPsll1[3],Shift_Amount[1],OPsll2[5]);
    mux2X1  sll_24 (OPsll1[4],OPsll1[2],Shift_Amount[1],OPsll2[4]);
    mux2X1  sll_23 (OPsll1[3],OPsll1[1],Shift_Amount[1],OPsll2[3]);
    mux2X1  sll_22 (OPsll1[2],OPsll1[0],Shift_Amount[1],OPsll2[2]);
    mux2X1  sll_21 (OPsll1[1],1'b0,Shift_Amount[1],OPsll2[1]);
    mux2X1  sll_20 (OPsll1[0],1'b0,Shift_Amount[1],OPsll2[0]);
    
    //1 bit shift left
    mux2X1  sll_07 (OPsll2[7],OPsll2[6],Shift_Amount[0],sll_wire[7]);
    mux2X1  sll_06 (OPsll2[6],OPsll2[5],Shift_Amount[0],sll_wire[6]);
    mux2X1  sll_05 (OPsll2[5],OPsll2[4],Shift_Amount[0],sll_wire[5]);
    mux2X1  sll_04 (OPsll2[4],OPsll2[3],Shift_Amount[0],sll_wire[4]);
    mux2X1  sll_03 (OPsll2[3],OPsll2[2],Shift_Amount[0],sll_wire[3]);
    mux2X1  sll_02 (OPsll2[2],OPsll2[1],Shift_Amount[0],sll_wire[2]);
    mux2X1  sll_01 (OPsll2[1],OPsll2[0],Shift_Amount[0],sll_wire[1]);
    mux2X1  sll_00 (OPsll2[0],1'b0,Shift_Amount[0],sll_wire[0]);
 
    //for sll 1'b0 for srl 1'b1
    
     mux2X1  choosing_07 (sll_wire[7],srl_wire[7],SelectOP,Result[7]);
     mux2X1  choosing_06 (sll_wire[6],srl_wire[6],SelectOP,Result[6]);
     mux2X1  choosing_05 (sll_wire[5],srl_wire[5],SelectOP,Result[5]);
     mux2X1  choosing_04 (sll_wire[4],srl_wire[4],SelectOP,Result[4]);
     mux2X1  choosing_03 (sll_wire[3],srl_wire[3],SelectOP,Result[3]);
     mux2X1  choosing_02 (sll_wire[2],srl_wire[2],SelectOP,Result[2]);
     mux2X1  choosing_01 (sll_wire[1],srl_wire[1],SelectOP,Result[1]);
     mux2X1  choosing_00 (sll_wire[0],srl_wire[0],SelectOP,Result[0]);


endmodule