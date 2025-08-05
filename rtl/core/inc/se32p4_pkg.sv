package se32p4_pkg;
    // ALU OPERATORS
    localparam logic [3:0] ALUOP_ADD  = 4'h0;
    localparam logic [3:0] ALUOP_SUB  = 4'h1;
    localparam logic [3:0] ALUOP_AND  = 4'h2;
    localparam logic [3:0] ALUOP_OR   = 4'h3;
    localparam logic [3:0] ALUOP_XOR  = 4'h4;
    localparam logic [3:0] ALUOP_SLT  = 4'h5;
    localparam logic [3:0] ALUOP_SLTU = 4'h6;
    localparam logic [3:0] ALUOP_SLL  = 4'h7;
    localparam logic [3:0] ALUOP_SRL  = 4'h8;
    localparam logic [3:0] ALUOP_SRA  = 4'h9;
    
    // CSR ADDRESS
    localparam logic [11:0] CSR_MSTATUS = 12'h300;
    localparam logic [11:0] CSR_MISA = 12'h301;
    
    // CSR OPERATORS
    localparam logic [1:0] CSROP_RW = 2'h0;
    localparam logic [1:0] CSROP_RS = 2'h1;
    localparam logic [1:0] CSROP_RC = 2'h2;
    
endpackage