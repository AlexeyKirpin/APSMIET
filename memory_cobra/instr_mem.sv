`timescale 1ns / 1ps
module instr_mem(
  input  logic [31:0] addr_i,
  output logic [31:0] read_data_o
);
  logic [31:0] memory [1024];
  initial $readmemh("example_prep.txt", memory);
  //initial $readmemh("example_converted.txt", memory);
  //initial $readmemh("test.txt", memory);
  
  always_comb begin
    if ( addr_i > 4095 )
      read_data_o <= 32'd0;
    else 
      read_data_o <= memory[ addr_i / 4 ]; 
  end
    
endmodule
