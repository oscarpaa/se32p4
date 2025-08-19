
module se32p4_core (

);

    se32p4_controller u_controller (
    
    );
    
    se32p4_f_stage u_f_stage (
    
    );
    
    se32p4_d_stage u_d_stage (
    
    );
    
    se32p4_e_stage u_e_stage (
    
    );
    
    se32p4_lsu u_lsu (
        .load_store_i(),
        .sign_i(),
        .byte_en_i(),
        .dat_i,
        .write_dat_o()
    );

endmodule