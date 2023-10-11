`timescale 1ns / 1ps

module CYBERcobra(
  input logic           clk_i,
  input logic           rst_i,
  input logic  [15:0]   sw_i,
  input logic  [31:0]   out_o
    );
    
logic [31:0] read_data_o_wire;
logic [31:0] result_o_wire; 
logic [31:0] a_i_wire;
logic [31:0] b_i_wire;
logic [31:0] write_data_i_wire;
logic [31:0] PC;  
logic [31:0] SE[0:2];
logic flag_o_alu;

assign SE[0] =  { { 9{read_data_o_wire[27]} }, read_data_o_wire[27:5] };
assign SE[1] =  { {16{read_data_o_wire[27]} }, sw_i[15:0] };
assign SE[2] =  { {22{read_data_o_wire[12]} }, read_data_o_wire[12:5], 2'd0 };
assign out_o = a_i_wire;

instr_mem instr_mem_inst(
  .addr_i      ( PC ),
  .read_data_o ( read_data_o_wire )
);

alu_riscv alu_riscv_inst(
  .a_i      ( a_i_wire ),
  .b_i      ( b_i_wire ),
  .alu_op_i ( read_data_o_wire[27:23] ),
  .flag_o   ( flag_o_alu ),
  .result_o ( result_o_wire )
);

rf_riscv rf_riscv_inst (
  .clk_i          ( clk_i ),
  .write_enable_i ( !(read_data_o_wire[30] || read_data_o_wire[31])),
  
  .write_addr_i   ( read_data_o_wire[4:0] ),
  .read_addr1_i   ( read_data_o_wire[22:18] ),
  .read_addr2_i   ( read_data_o_wire[17:13] ),
  
  .write_data_i   ( write_data_i_wire ),
  .read_data1_o   ( a_i_wire ),
  .read_data2_o   ( b_i_wire )
);

always_comb begin
  case ( read_data_o_wire[29:28] )
    2'd0: write_data_i_wire <= SE[0];         
    2'd1: write_data_i_wire <= result_o_wire;
    2'd2: write_data_i_wire <= SE[1];         
    2'd3: write_data_i_wire <= 32'd0;
  endcase
end

always_ff @( posedge clk_i or posedge rst_i ) begin
  if ( rst_i ) 
    PC <= '0;
  else if ( (read_data_o_wire[30] && flag_o_alu) || read_data_o_wire[31] )
    PC <= PC + SE[2];
  else 
    PC <= PC + 32'd4;
end

endmodule