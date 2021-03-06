`timescale 1ns / 1ps

module HazardUnit #(parameter WIDTH=32)
   (
    input 	 clk,
    input [4:0]  RsD,
    input [4:0]  RtD,
    input [4:0]  RsE,
    input [4:0]  RtE,
    input [4:0]  WriteRegE,
    input 	 MemtoRegE,
    input 	 RegWriteE, 
    input [4:0]  WriteRegM,
    input 	 MemtoRegM,
    input 	 RegWriteM,
    input [4:0]  WriteRegW,
    input 	 RegWriteW,
    input 	 PCSrcD,
	 input    BranchED,
	 input    BranchNED,
	 input    Branch2RegD,
	 input    Branch2ValueD,
    output 	 StallF,
    output 	 StallD,
    output 	 ForwardAD,
    output 	 ForwardBD,
	 output   ForwardADN1,
	 output   ForwardBDN1,
	 output   ForwardADN2,
	 output   ForwardBDN2,
    output 	 FlushE,
    output [1:0] ForwardAE,
    output [1:0] ForwardBE
    );
	 
reg [1:0] countreg;

   // Yahan clock lao fir counter lagake 1 ya 2 cycle wait karo
   assign ForwardAD = ((RsD==WriteRegM)&RegWriteM)?1'b1:1'b0;
   assign ForwardBD = ((RtD==WriteRegM)&RegWriteM)?1'b1:1'b0;
   assign ForwardAE = ((RsE==WriteRegM)&RegWriteM)?2'b10:((RsE==WriteRegW)&RegWriteW)?2'b01:2'b00;
   assign ForwardBE = ((RtE==WriteRegM)&RegWriteM)?2'b10:((RtE==WriteRegW)&RegWriteW)?2'b01:2'b00;
   assign ForwardADN1 = ((BranchED|BranchNED|Branch2RegD|Branch2ValueD)&(RsD==WriteRegE)&RegWriteE)?1'b1:1'b0;
	assign ForwardBDN1 = ((BranchED|BranchNED|Branch2RegD|Branch2ValueD)&(RtD==WriteRegE)&RegWriteE)?1'b1:1'b0;
	assign ForwardADN2 = ((BranchED|BranchNED|Branch2RegD|Branch2ValueD)&(RsD==WriteRegW)&RegWriteW)?1'b1:1'b0;
	assign ForwardBDN2 = ((BranchED|BranchNED|Branch2RegD|Branch2ValueD)&(RtD==WriteRegW)&RegWriteW)?1'b1:1'b0;
	
assign StallF=((RsD==WriteRegE|RtD==WriteRegE)&MemtoRegE)?1'b1:(PCSrcD==1&(countreg==2'b00|countreg==2'b01))?1'b1:1'b0;
assign StallD=((RsD==WriteRegE|RtD==WriteRegE)&MemtoRegE)?1'b1:(PCSrcD==1&(countreg==2'b00|countreg==2'b01|countreg==2'b10))?1'b1:1'b0;
assign FlushE=((RsD==WriteRegE|RtD==WriteRegE)&MemtoRegE)?1'b1:(PCSrcD==1&(countreg==2'b00|countreg==2'b01|countreg==2'b10))?1'b1:1'b0;
   
initial
countreg=2'b00;
	
always @(posedge clk)
	begin
		case(countreg)
		2'b00:if(PCSrcD==1)countreg<=2'b01;
		2'b01:if(PCSrcD==1)countreg<=2'b10;
		2'b10:if(PCSrcD==1)countreg<=2'b11;
		2'b11:if(PCSrcD==1)countreg<=2'b00;
		endcase
	end
	
endmodule // HazardUnit
