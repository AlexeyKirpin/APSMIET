`timescale 1ns / 1ps

module data_mem(
  input  logic        clk_i,
  input  logic        mem_req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o
    );
  
  logic [31:0] memory [4096];
  logic [31:0] temp;
  
  always_ff @( posedge clk_i ) begin
    if ( write_enable_i && mem_req_i )
      memory[ addr_i / 4 ] <= write_data_i;
  end
  
  always_ff @( posedge clk_i ) begin
    if ( mem_req_i )
      temp <= memory[ addr_i / 4 ];
  end
  
  always_comb begin
    if ( !mem_req_i || write_enable_i )
      read_data_o <= 32'hfa11_1eaf;
    else if ( mem_req_i && ( addr_i < 16384) )
      read_data_o <= temp;
    else if ( mem_req_i && ( addr_i > 16383) )
      read_data_o <= 32'hdead_beef;
  end
  
endmodule
