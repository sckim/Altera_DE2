module proc(DIN, Resetn, Clock, Run, DOUT, ADDR, W, Done);
	input [15:0] DIN;
	input Resetn, Clock, Run;
	output wire [15:0] DOUT;
	output wire [15:0] ADDR;
	output wire W;
	output Done;

	reg [15:0] BusWires;
	reg [0:7] Rin, Rout;
	reg [15:0] Sum;
	reg IRin, ADDRin, Done, DINout, DOUTin, Ain, Gin, Gout, AddSub;
	wire [2:0] Tstep_Q;
	wire [2:0] I;
	wire [0:7] Xreg, Yreg;
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7 /* pc */, A, G;
	wire [1:9] IR;
	wire [1:10] Sel; // bus selector
	reg pc_inc, W_D;
	wire Z, Z_D;
	
	wire Clear = ~Resetn | Done | (~Run & (Tstep_Q == 0));
	upcount Tstep (Clear, Clock, Tstep_Q);
	assign I = IR[1:3];
	dec3to8 decX (IR[4:6], 1'b1, Xreg);
	dec3to8 decY (IR[7:9], 1'b1, Yreg);
	
	/* Instruction Table
	* 	000: mv		Rx,Ry				: Rx <- [Ry]
	* 	001: mvi		Rx,#D				: Rx <- D
	* 	010: add		Rx,Ry				: Rx <- [Rx] + [Ry]
	* 	011: sub		Rx,Ry				: Rx <- [Rx] - [Ry]
	* 	100: ld		Rx,[Ry]			: Rx <- [[Ry]]
	* 	101: st		Rx,[Ry]			: [Ry] <- [Rx]
	* 	110: mvnz	Rx,Ry				: if Z != 1, Rx <- [Ry]
	* 	OPCODE format: III XXX YYY UUUUUUU, where 
	* 	III = instruction, XXX = Rx, YYY = Ry, and U = unused bit. For mvi,
	* 	a second word of data is read in the following clock cycle
	*/
  	// R7 is the program counter
	always @(Tstep_Q or I or Xreg or Yreg or Z or Run)
	begin
		Done = 1'b0; Ain = 1'b0; Gin = 1'b0; Gout = 1'b0; AddSub = 1'b0;
		IRin = 1'b0; DINout = 1'b0; DOUTin = 1'b0; ADDRin = 1'b0; W_D = 1'b0;
		Rin = 8'b0; Rout = 8'b0; pc_inc = 1'b0;
		case (Tstep_Q)
			3'b000: // fetch the instruction
				begin
					Rout = 8'b00000001;	// R7 is program counter (pc)
					ADDRin = 1'b1;
					pc_inc = Run; // to increment pc
				end
			3'b001: // wait cycle for synchronous memory
				// in case the instruction turns out to be mvi, read memory
				begin
					Rout = 8'b00000001;	// R7 is program counter (pc)
					ADDRin = 1'b1;
				end
			3'b010: // store DIN in IR 
				begin
					IRin = 1'b1;
				end
			3'b011:   //define signals in T3
				case (I)
					3'b000: // mv Rx,Ry
					begin
						Rout = Yreg;
						Rin = Xreg;
						Done = 1'b1;
					end
					3'b001: // mvi Rx,#D
					begin
						// data is available now on DIN
						DINout = 1'b1;
						Rin = Xreg; 
						pc_inc = 1'b1;
						Done = 1'b1;
					end
					3'b010, 3'b011: //add, sub 
					begin
						Rout = Xreg;
						Ain = 1'b1;
					end
					3'b100: // ld Rx,[Ry]
					begin
						Rout = Yreg;
						ADDRin = 1'b1; 
					end
					3'b101: // st [Ry],Rx
					begin
						Rout = Yreg;
						ADDRin = 1'b1; 
					end
					3'b110: // mvnz Rx,Ry
					begin
						if (!Z)
						begin
							Rout = Yreg;
							Rin = Xreg;
						end
						else
						begin
							Rout = 8'b0;
				 			Rin = 8'b0;
						end
						Done = 1'b1;
					end
					default: ;
			   endcase
			3'b100:   //define signals T4
				case (I)
					3'b010: // add
					begin
						Rout = Yreg;
						Gin = 1'b1;
					end
					3'b011: // sub
					begin
						Rout = Yreg;
						AddSub = 1'b1;
						Gin = 1'b1;
					end
					3'b100: // ld Rx,[Ry]
						; // wait cycle for synchronous memory
					3'b101: // st [Ry],Rx
					begin
						Rout = Xreg;
						DOUTin = 1'b1; 
						W_D = 1'b1;
					end
					default: ; 
				endcase
			3'b101:   //define T5
				case (I)
					3'b010, 3'b011: //add, sub
					begin
						Gout = 1'b1;
						Rin = Xreg;
						Done = 1'b1;
					end
					3'b100: // ld Rx,[Ry]
					begin
						DINout = 1'b1;
						Rin = Xreg;
						Done = 1'b1;
					end
					3'b101: // st [Ry],Rx
					begin
						Done = 1'b1; // wait cycle for synhronous memory
					end
					default: ;
				endcase
			default: ;
		endcase
	end	
	
	regn reg_0 (BusWires, Rin[0], Clock, R0);
	regn reg_1 (BusWires, Rin[1], Clock, R1);
	regn reg_2 (BusWires, Rin[2], Clock, R2);
	regn reg_3 (BusWires, Rin[3], Clock, R3);
	regn reg_4 (BusWires, Rin[4], Clock, R4);
	regn reg_5 (BusWires, Rin[5], Clock, R5);
	regn reg_6 (BusWires, Rin[6], Clock, R6);

	// R7 is program counter
	// module pc_count(R, Resetn, Clock, E, L, Q);
	pc_count pc (BusWires, Resetn, Clock, pc_inc, Rin[7], R7);

	regn reg_A (BusWires, Ain, Clock, A);
	regn reg_DOUT (BusWires, DOUTin, Clock, DOUT);
	regn reg_ADDR (BusWires, ADDRin, Clock, ADDR);
	regn #(.n(9)) reg_IR (DIN[15:7], IRin, Clock, IR);

	flipflop reg_W (W_D, Resetn, Clock, W);

	//	alu
	always @(AddSub or A or BusWires)
		begin
		if (!AddSub)
			Sum = A + BusWires;
	    else
			Sum = A - BusWires;
		end

	regn reg_G (Sum, Gin, Clock, G);

	assign Z_D = (G == 0) ? 1'b1 : 1'b0;
	flipflop reg_Z (Z_D, Resetn, Clock, Z);

	// define the internal processor bus
	assign Sel = {Rout, Gout, DINout};

	always @(*)
	begin
		if (Sel == 10'b1000000000)
			BusWires = R0;
   	else if (Sel == 10'b0100000000)
			BusWires = R1;
		else if (Sel == 10'b0010000000)
			BusWires = R2;
		else if (Sel == 10'b0001000000)
			BusWires = R3;
		else if (Sel == 10'b0000100000)
			BusWires = R4;
		else if (Sel == 10'b0000010000)
			BusWires = R5;
		else if (Sel == 10'b0000001000)
			BusWires = R6;
		else if (Sel == 10'b0000000100)
			BusWires = R7;
		else if (Sel == 10'b0000000010)
			BusWires = G;
   	else BusWires = DIN;
	end	
endmodule

module upcount(Clear, Clock, Q);
	input Clear, Clock;
	output [2:0] Q;
	reg [2:0] Q;
	
	always @(posedge Clock)
	 	if (Clear)
			Q <= 3'b0;
		else 
			Q <= Q + 1'b1;
endmodule

module pc_count(R, Resetn, Clock, E, L, Q);
	input [15:0] R;
	input Resetn, Clock, E, L;
	output [15:0] Q;
	reg [15:0] Q;
	
	always @(posedge Clock)
	 	if (!Resetn)
			Q <= 16'b0;
		else if (L)
			Q <= R;
		else if (E)
			Q <= Q + 1'b1;
endmodule

module dec3to8(W, En, Y);
	input [2:0] W;
	input En;
	output [0:7] Y;
	reg [0:7] Y;
	
	always @(W or En)
	begin
		if (En == 1)
			case (W)
				3'b000: Y = 8'b10000000;
	   	   3'b001: Y = 8'b01000000;
				3'b010: Y = 8'b00100000;
				3'b011: Y = 8'b00010000;
				3'b100: Y = 8'b00001000;
				3'b101: Y = 8'b00000100;
				3'b110: Y = 8'b00000010;
				3'b111: Y = 8'b00000001;
			endcase
		else 
			Y = 4'b00000000;
	end
endmodule

module regn(R, Rin, Clock, Q);
	parameter n = 16;
	input [n-1:0] R;
	input Rin, Clock;
	output [n-1:0] Q;
	reg [n-1:0] Q;

	always @(posedge Clock)
	 	if (Rin)
			Q <= R;
endmodule
