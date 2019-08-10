// LPM RAM module
// inputs: 
// 	Clock
//		Address
//		Write: asserted to perform a write
//		DataIn: data to be written
//
// outputs:
//		DataOut: data read
module part1 (Clock, DataIn, DataOut, Address, Write);
	input Clock, Write;
	input [7:0] DataIn;
	output [7:0] DataOut;
	input [4:0] Address;
	
	// instantiate LPM module
	// module ramlpm (address, clock, data, wren, q);
	ramlpm m32x8 (Address, Clock, DataIn, Write, DataOut);
endmodule
