package se32p4_pkg;
    // Operation codes RV32I
    localparam logic [6:0] OP_ALUI  = 7'b0010011; // I-type - ALU operation with immediate
    localparam logic [6:0] OP_ALUR  = 7'b0110011; // R-type - ALU operation with registers
    localparam logic [6:0] OP_LUI   = 7'b0110111; // U-type - load upper immediate
    localparam logic [6:0] OP_AUIPC = 7'b0010111; // U-type - add upper immediate to PC
    
    localparam logic [6:0] OP_LOAD  = 7'b0000011; // I-type - load
    localparam logic [6:0] OP_STORE = 7'b0100011; // S-type - store
    
    localparam logic [6:0] OP_BRANCH = 7'b1100011; // B-type - branches
    localparam logic [6:0] OP_JALR   = 7'b1100111; // I-type - jump and link with register
    localparam logic [6:0] OP_JAL    = 7'b1101111; // J-type - jump and link

    localparam logic [6:0] OP_PRIVILEGED = 7'b1110011; // Privileged instructions
    
    // funct3 RV32I
    localparam logic [2:0] F3_BEQ  = 3'b000; // branch if equal
    localparam logic [2:0] F3_BNE  = 3'b001; // branch if not equal
    localparam logic [2:0] F3_BLT  = 3'b100; // branch if less than
    localparam logic [2:0] F3_BGE  = 3'b101; // branch if greater than or equal
    localparam logic [2:0] F3_BLTU = 3'b110; // branch if less than (unsigned)
    localparam logic [2:0] F3_BGEU = 3'b111; // branch if greater than or equal (unsigned)
    
    localparam logic [2:0] F3_LB_SB  = 3'b000; // load / store byte
    localparam logic [2:0] F3_LH_SH  = 3'b001; // load / store half word
    localparam logic [2:0] F3_LW_SW  = 3'b010; // load / store word
    localparam logic [2:0] F3_LBU  = 3'b100; // load byte (unsigned)
    localparam logic [2:0] F3_LHU  = 3'b101; // load half word (unsigned)
    
    localparam logic [2:0] F3_SUB_ADD = 3'b000; // sub/add
    localparam logic [2:0] F3_SLL  = 3'b001; // shift logical left
    localparam logic [2:0] F3_SLT  = 3'b010; // set on less
    localparam logic [2:0] F3_SLTU = 3'b011; // set on less unsigned
    localparam logic [2:0] F3_XOR  = 3'b100; // xor
    localparam logic [2:0] F3_SR   = 3'b101; // shift right
    localparam logic [2:0] F3_OR   = 3'b110; // or
    localparam logic [2:0] F3_AND  = 3'b111; // and

    localparam logic [2:0] F3_CSRRW  = 3'b001;
    localparam logic [2:0] F3_CSRRS  = 3'b010;
    localparam logic [2:0] F3_CSRRC  = 3'b011;
    localparam logic [2:0] F3_CSRRWI = 3'b101;
    localparam logic [2:0] F3_CSRRSI = 3'b110;
    localparam logic [2:0] F3_CSRRCI = 3'b111;


    // Operation codes RV32C
    typedef enum logic [3:0] {CNONE_T, CR_T, CI_T, CS_T, CSA_T, CB_T, CBA_T, CJ_T, CSS_T, CIW_T, CL_T} cformat_t;
    
    localparam logic [1:0] OPC_ZERO = 2'h0;
    localparam logic [1:0] OPC_ONE  = 2'h1;
    localparam logic [1:0] OPC_TWO  = 2'h2;

    // funct3 RV32C
    localparam logic [2:0] F3C_LW_LWSP = 3'b010;
    localparam logic [2:0] F3C_SW_SWSP = 3'b110;
 
    localparam logic [2:0] F3C_JAL = 3'b001;
    localparam logic [2:0] F3C_J   = 3'b101;
    
    localparam logic [2:0] F3C_BEQZ = 3'b110;
    localparam logic [2:0] F3C_BNEZ = 3'b111;
    
    localparam logic [2:0] F3C_ADDI         = 3'b000;
    localparam logic [2:0] F3C_ADDI4SPN     = 3'b000;
    localparam logic [2:0] F3C_ADDI16SP_LUI = 3'b011;
    localparam logic [2:0] F3C_LI           = 3'b010;
    
    localparam logic [2:0] F3C_ALU = 3'b100;
    localparam logic [1:0] FC_SRLI = 2'b00;
    localparam logic [1:0] FC_SRAI = 2'b01;
    localparam logic [1:0] FC_ANDI = 2'b10;
    
    localparam logic [2:0] F3C_SLLI   = 3'b000;
    
    localparam logic [5:0] F6C_CSA    = 6'b100011;
    localparam logic [2:0] F6C_LO_CSA = 3'b011;    
    
    localparam logic [1:0] F2C_SUB     = 2'b00;
    localparam logic [1:0] F2C_XOR     = 2'b01;
    localparam logic [1:0] F2C_OR      = 2'b10;
    localparam logic [1:0] F2C_AND     = 2'b11;
    
    localparam logic [3:0] F4C_JR_MV    = 4'b1000;
    localparam logic [3:0] F4C_JALR_ADD = 4'b1001;
    localparam logic [2:0] F4C_HI_CR    = 3'b100;

    // MEMORY ENABLE
    typedef struct packed {
        logic read_en;
        logic write_en;
    } mem_rw_en_t;

    // PC SEL MODES
    typedef enum logic [1:0] {SEL_PC_PLUS, SEL_PC_TARGET, SEL_JALR} sel_pc_t;

    // BRANCH TYPES
    typedef enum logic [2:0] {BRANCH_NONE, BRANCH_BEQ, BRANCH_BNE, BRANCH_BLT, BRANCH_BGE} branch_t;

    // WRITE TO REGFILE SELECT
    typedef enum logic [2:0] {
        W_REG_NONE, 
        W_REG_ALURES, 
        W_REG_READ_DATA, 
        W_REG_IMMEDIATE, 
        W_REG_CSR, 
        W_REG_PC_PLUS, 
        W_REG_PC_TARGET
    } sel_wreg_t;

    typedef enum logic [1:0] {LSU_NONE, LSU_LOAD, LSU_STORE} sel_lsu_t; 
    
    // ALU OPERATORS
    typedef enum logic [3:0] {
        ALUOP_NONE,
        ALUOP_ADD,
        ALUOP_SUB,
        ALUOP_AND,
        ALUOP_OR,
        ALUOP_XOR,
        ALUOP_SLT,
        ALUOP_SLTU,
        ALUOP_SLL,
        ALUOP_SRL,
        ALUOP_SRA
    } aluop_t;
    
    // CSR ADDRESS
    localparam logic [11:0] CSR_MSTATUS = 12'h300;
    localparam logic [11:0] CSR_MISA = 12'h301;
    
    // CSR OPERATORS
    typedef enum logic [1:0] {CSROP_NONE, CSROP_RW, CSROP_RS, CSROP_RC} csrop_t;
    
endpackage