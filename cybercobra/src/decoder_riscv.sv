`timescale 1ns / 1ps

module decoder_riscv (
  input  logic [31:0]  fetched_instr_i,
  output logic [1:0]   a_sel_o,
  output logic [2:0]   b_sel_o,
  output logic [4:0]   alu_op_o,
  output logic [2:0]   csr_op_o,
  output logic         csr_we_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [2:0]   mem_size_o,
  output logic         gpr_we_o,
  output logic [1:0]   wb_sel_o,
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o
);
  import riscv_pkg::*;
  import alu_opcodes_pkg::*;
  import csr_pkg::*;


  logic [6:0] opcode;
  assign opcode = fetched_instr_i[6:0];

  logic [2:0] func3;
  assign func3  = fetched_instr_i[14:12];

  logic [6:0] func7;
  assign func7  = fetched_instr_i[31:25];


  always_comb
  begin
    a_sel_o <= 2'd0;
    b_sel_o <= 3'd0;
    wb_sel_o <= 2'd0;
    alu_op_o <= 5'd0;
    csr_we_o <= 1'd0;
    csr_op_o <= 3'd0;
    mem_req_o <= 1'd0;
    mem_we_o <= 1'd0;
    gpr_we_o <= 1'd0;
    illegal_instr_o <= 1'd0;
    branch_o <= 1'd0;
    jal_o <= 1'd0;
    jalr_o <= 1'd0;
    mret_o <= 1'd0;
    if(opcode[1:0] == 2'b11)
    begin
      case(opcode[6:2])


        OP_OPCODE: case(func3)
          3'd0:
          begin
              case(func7)
                7'd0:    //add
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_ADD;
                  gpr_we_o <= 1'd1;
                end
                7'h20:    //sub
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_SUB;
                  gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
          end
            3'd4:
            begin    //xor
              case(func7)
                7'd0:
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_XOR;
                  gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd6: //or
            begin
              case(func7)
                7'd0:
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_OR;
                  gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd7: //and
            begin
              case(func7)
                7'd0:
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_AND;
                  gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd1: //sll
            begin
              case(func7)
                7'd0:
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_SLL;
                  gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd5: 
            begin
              case(func7)
                7'd0: //srl
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_SRL;
                  gpr_we_o <= 1'd1;
                end
                7'h20: //sra
                begin
                a_sel_o <= 2'd0;
                b_sel_o <= 3'd0;
                alu_op_o <= ALU_SRA;
                gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd2:
            begin
              case(func7)
                7'd0: //slt
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_SLTS;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd3:
            begin
              case(func7)
                7'd0: //sltu
                begin
                  a_sel_o <= 2'd0;
                  b_sel_o <= 3'd0;
                  alu_op_o <= ALU_SLTU;
                  gpr_we_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
        endcase


      OP_IMM_OPCODE: case(func3) 
          3'd0: // add with const. addi
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            alu_op_o <= ALU_ADD;
            gpr_we_o <= 1'd1;
          end 
          3'd4: // XOR with const. xori
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            alu_op_o <= ALU_XOR;
            gpr_we_o <= 1'd1;
          end 
          3'd6: // OR with const. ori
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            alu_op_o <= ALU_OR;
            gpr_we_o <= 1'd1;
          end 
          3'd7: // AND with const. andi
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            alu_op_o <= ALU_AND;
            gpr_we_o <= 1'd1;
          end 
          3'd1: //slli
          begin
            if (func7 == 7'd0) //logical shift left
            begin
              a_sel_o <= 2'd0;
              b_sel_o <= 3'd1;
              alu_op_o <= ALU_SLL;
            end
            else illegal_instr_o <= 1'd1;
          end
          3'd5:
          begin 
            case(func7)
              7'd0:  //logical shift right. srli
              begin
                a_sel_o <= 2'd0;
                b_sel_o <= 3'd1;
                alu_op_o <= ALU_SRL;
              end
              7'h20:  //arithmetic shift right. srai
              begin
                a_sel_o <= 2'd0;
                b_sel_o <= 3'd1;
                alu_op_o <= ALU_SRA;
                gpr_we_o <= 1'd1;
              end
              default: illegal_instr_o <= 1'd1;
            endcase
          end
          3'd2:
          begin
            case(func7) //slti
              7'd0: //result of comparison
              begin
                a_sel_o <= 2'd0;
                b_sel_o <= 3'd1;
                alu_op_o <= ALU_SLTS;
                gpr_we_o <= 1'd1;
              end
              default: illegal_instr_o <= 1'd1;
            endcase
          end
          3'd3:
          begin
            case(func7) //sltiu
              7'd0: //Unsigned comparison
              begin
                a_sel_o <= 2'd0;
                b_sel_o <= 3'd1;
                alu_op_o <= ALU_SLTU;
                gpr_we_o <= 1'd1;
              end
              default: illegal_instr_o <= 1'd1;
            endcase
          end
          default: illegal_instr_o <= 1'd1;
        endcase


        LOAD_OPCODE: case(func3)
          3'd0: //lb
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            wb_sel_o <= 2'd1;
            gpr_we_o <= 1'd1;
            alu_op_o <= ALU_ADD;
            mem_size_o <= LDST_B;
            mem_req_o <= 1'd1;
          end
          3'd1: //lh
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            wb_sel_o <= 2'd1;
            gpr_we_o <= 1'd1;
            alu_op_o <= ALU_ADD;
            mem_size_o <= LDST_H;
            mem_req_o <= 1'd1;
          end
          3'd2: //lw
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            wb_sel_o <= 2'd1;
            gpr_we_o <= 1'd1;
            alu_op_o <= ALU_ADD;
            mem_size_o <= LDST_W;
            mem_req_o <= 1'd1;
          end
          3'd4: //lbu
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            wb_sel_o <= 2'd1;
            gpr_we_o <= 1'd1;
            alu_op_o <= ALU_ADD;
            mem_size_o <= LDST_BU;
            mem_req_o <= 1'd1;
          end
          3'd5: //lhu
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd1;
            wb_sel_o <= 2'd1;
            gpr_we_o <= 1'd1;
            alu_op_o <= ALU_ADD;
            mem_size_o <= LDST_HU;
            mem_req_o <= 1'd1;
          end
        default: illegal_instr_o <= 1'd1;
        endcase


        STORE_OPCODE: case(func3) 
          3'd0: //sb
          begin
            b_sel_o <= 3'd3;
            mem_req_o <= 1'd1;
            mem_we_o <= 1'd1;
            mem_size_o <= LDST_B;
          end
          3'd1: //sh
          begin
            mem_req_o <= 1'd1;
            mem_we_o <= 1'd1;
            mem_size_o <= LDST_H;
            b_sel_o <= 3'd3;
          end
          3'd2: //sw
          begin
            b_sel_o <= 3'd3;
            mem_req_o <= 1'd1;
            mem_we_o <= 1'd1;
            mem_size_o <= LDST_W;
          end
          default: illegal_instr_o <= 1'd1;
        endcase


        BRANCH_OPCODE: case(func3) 
          3'd0: //beq
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd0;
            alu_op_o <= ALU_EQ;
            branch_o <= 1'd1;
          end
          3'd1: //bne
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd0;
            alu_op_o <= ALU_NE;
            branch_o <= 1'd1;
          end
          3'd4: //blt
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd0;
            alu_op_o <= ALU_LTS;
            branch_o <= 1'd1;
          end
          3'd5: //bge
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd0;
            alu_op_o <= ALU_GES;
            branch_o <= 1'd1;
          end
          3'd6: //bltu
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd0;
            alu_op_o <= ALU_LTU;
            branch_o <= 1'd1;
          end
          3'd7: //bgeu
          begin
            a_sel_o <= 2'd0;
            b_sel_o <= 3'd0;
            alu_op_o <= ALU_GEU;
            branch_o <= 1'd1;
          end
          default: illegal_instr_o <= 1'd1;
        endcase


        JAL_OPCODE: //jal
        begin
          a_sel_o <= 2'd1;
          b_sel_o <= 3'd4;
          alu_op_o <= '0;
          jal_o <= 1'd1;
          gpr_we_o <= 1'd1;
        end


        JALR_OPCODE: begin
          case(func3)
            3'd0: //jalr
            begin
              a_sel_o <= 2'd1;
              b_sel_o <= 3'd4;
              jalr_o <= 1'd1;
              gpr_we_o <= 1'd1;
            end
            default: illegal_instr_o <= 1'd1;
          endcase
        end


        LUI_OPCODE: begin //lui
          a_sel_o <= 2'd2;
          b_sel_o <= 3'd2;
          gpr_we_o <= 1'd1;
          wb_sel_o <= 2'd0;
        end


        AUIPC_OPCODE:
        begin
          a_sel_o <= 2'd1; //auipc
          b_sel_o <= 3'd2;
          alu_op_o <= ALU_ADD;
          gpr_we_o <= 1'd1;
        end 


        MISC_MEM_OPCODE: if(func3 == 3'd0)
        begin
        end


        SYSTEM_OPCODE: begin
          case(func3)
            3'd0: begin
              case(func7)
                7'd0: //ecall
                begin
                  illegal_instr_o <= 1'd1;
                end
                7'd1: //ebreak
                begin
                  illegal_instr_o <= 1'd1;
                end
                default: illegal_instr_o <= 1'd1;
              endcase
            end
            3'd1: //csrrw
            begin
              a_sel_o <= 2'd0;
              csr_op_o <= CSR_RW;
              csr_we_o <= 1'd1;
            end
            3'd2: //csrrs
            begin
              a_sel_o <= 2'd0;
              csr_op_o <= CSR_RS;
              csr_we_o <= 1'd1;
            end
            3'd3: //csrrc
            begin
              a_sel_o <= 2'd0;
              csr_op_o <= CSR_RC;
              csr_we_o <= 1'd1;
            end
            3'd5: //csrrwi
            begin
              b_sel_o <= 3'd1;
              csr_op_o <= CSR_RWI;
              csr_we_o <= 1'd1;
            end
            3'd6: //csrrsi
            begin
              b_sel_o <= 3'd1;
              csr_op_o <= CSR_RSI;
              csr_we_o <= 1'd1;
            end
            3'd7: //csrrci
            begin
              b_sel_o <= 3'd1;
              csr_op_o <= CSR_RCI;
              csr_we_o <= 1'd1;
            end
            default: illegal_instr_o <= 1'd1;
          endcase
        end
    default: illegal_instr_o <= 1'd1;
      endcase
    end
    else begin
      illegal_instr_o <= 1'd1;
    end
  end



endmodule