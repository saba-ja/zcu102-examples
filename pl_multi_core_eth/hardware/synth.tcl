source -notrace ../../script/proj_gen.tcl

proc create_target {} {
        # Get the current time as a Unix timestamp
        set currentTime [clock seconds]

        # Format the timestamp into the desired format
        set formattedTime [clock format $currentTime -format {%Y%m%d_%H%M%S}]

        set proj_name "zcu102_ps_eth${formattedTime}_"
        
        set origin_dir "."
        
        # Set project info
        ::proj::set_proj_info                            \
            -force                                       \
            -part "xczu9eg-ffvb1156-2-e"                 \
            -board_part "xilinx.com:zcu102:part0:3.4"    \
            -addr "$origin_dir"                          \
            -name "$proj_name"

        ::proj::generate_project

        # Add source files
        ::proj::create_src_filesets -base_folder $origin_dir

        # Add block design
        set bd_file_name "system_bd"
        ::proj::create_block_design -bd_file $bd_file_name \
                                    -design_name "system"  \
                                    -validate 1            \
                                    -base_folder $origin_dir

        ::proj::create_bd_wrapper -bd_name "system" -is_top 1
        
        close_bd_design [get_bd_designs "system"]        

        # Add constraint files
        ::proj::create_constr_filesets -base_folder $origin_dir
        update_compile_order -fileset sources_1

        # Build the project
        puts "--- Building project"
        # ::proj::build_proj
        
        # wait_on_run impl_1

        # puts "--- Export bitstream"
        # set xil_proj [::proj::get_project_name]
        # ::proj::export_proj_bitstream -destination "$origin_dir/build/export_${xil_proj}"
        
    }

create_target 

