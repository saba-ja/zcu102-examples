# -----------------------------------------------------------------------------
# Originator: S. Janamian
# Date: 7/6/2023
#
# This TCL file contains general procs to set a vivado project info
# and populate the project based on the given parameters
#
# -----------------------------------------------------------------------------

namespace eval ::proj {
    # Declare proj_dict within the namespace
    variable proj_dict
    variable _xil_proj_name_

    proc set_proj_info {args} {
        variable proj_dict
        set proj [dict create             \
            force               0         \
            proj_name           "proj_"   \
            proj_addr           "."       \
            proj_board          ""        \
            proj_board_part     ""        \
            proj_part           ""        \
            proj_src            "src"     \
            proj_sim            "sim"     \
            proj_constr         "constr"  \
            proj_bd             "bd"      \
            proj_ip_repo        "ip_repo" \
            proj_build_dir_name "build"
        ]

        # Parse command-line arguments
        set i 0
        while {$i < [llength $args]} {
            set arg [lindex $args $i]
            switch -- $arg {
                "-force" {
                    dict set proj force 1
                }
                "-name" {
                    dict set proj proj_name [lindex $args [expr $i+1]]
                    incr i
                }
                "-addr" {
                    dict set proj proj_addr [lindex $args [expr $i+1]]
                    incr i
                }
                "-board" {
                    dict set proj proj_board [lindex $args [expr $i+1]]
                    incr i
                }
                "-board_part" {
                    dict set proj proj_board_part [lindex $args [expr $i+1]]
                    incr i
                }
                "-part" {
                    dict set proj proj_part [lindex $args [expr $i+1]]
                    incr i
                }
                "-src" {
                    dict set proj proj_src [lindex $args [expr $i+1]]
                    incr i
                }
                "-sim" {
                    dict set proj proj_sim [lindex $args [expr $i+1]]
                    incr i
                }
                "-constr" {
                    dict set proj proj_constr [lindex $args [expr $i+1]]
                    incr i
                }
                "-bd_folder" {
                    dict set proj proj_bd [lindex $args [expr $i+1]]
                    incr i
                }
                "-ip_repo" {
                    dict set proj proj_ip_repo [lindex $args [expr $i+1]]
                    incr i
                }

                "-help" {
                    puts "Usage: generate_project ?options?\n"
                    puts "Options:"
                    puts "  -force         Force overwrite of existing project"
                    puts "  -name          name of the project"
                    puts "  -addr          address of the project"
                    puts "  -board         development board with board support package"
                    puts "  -board_part    development board part"
                    puts "  -part          Xilinx chip part number"
                    puts "  -src           relative path to the source folder"
                    puts "  -sim           relative path to the simulation folder"
                    puts "  -constr        relative path to the constraint folder"
                    puts "  -bd_folder     relative path to folder containing block design tcl files"
                    puts "  -ip_repo       ip repo relative address"
                    puts "  -help          Display this help message"
                    return
                }
                default {
                    puts "Warning: Unknown argument $arg"
                }
            }
            incr i
        }

        check_vivado_tool
        set proj_dict $proj
    }

    proc proj_close {} {
        # Close any open project (including the one created by this script)
        catch {close_project}

        # Clear existing project settings
        if {[info exists project]} {
            unset project
        }
    }

    proc generate_project {} {
        variable proj_dict
        proj_close
        set_project_name
        create_project_and_set_properties
        create_ip_repo_path
        create_sim_filesets
    }

    proc get_toolversion {} {
        # Vivado version
        set toolversion [lindex [split [version -short] .] 0]
        if {![string length $toolversion]} {
            error "Error: tool version could not be detected!"
        }
        return $toolversion
    }

    proc check_vivado_tool {} {
        set toolname [file rootname [file tail [info nameofexecutable]]]
        if {![string equal $toolname "vivado"]} {
            error "Error: unexpected tool name '$toolname'!"
        }

        set toolversion [get_toolversion]

        # Vivado Block Design version requirement
        if {$toolversion < 2019} {
            error "Error, this project requires Vivado 2019 or newer!"
        }
    }

    # Function to set origin directory and project name
    proc set_project_name {} {
        variable proj_dict
        variable _xil_proj_name_

        # Set the project name
        set _xil_proj_name_ [dict get $proj_dict "proj_name"]

        # default project name appended with commitID
        set commitID [exec git rev-parse HEAD]
        append _xil_proj_name_ [string range $commitID 0 5]
    }

    # Function to set origin directory and project name
    proc get_project_name {} {
        variable proj_dict

        # Set the project name
        set xil_proj_name [dict get $proj_dict "proj_name"]

        # default project name appended with commitID
        set commitID [exec git rev-parse HEAD]
        append xil_proj_name [string range $commitID 0 5]
        return $xil_proj_name
    }


    # Function to create project
    proc create_project_and_set_properties {} {
        variable proj_dict
        variable _xil_proj_name_

        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        # Close any open project
        catch {close_project}

        # Create project
        set build_folder [dict get $proj_dict "proj_build_dir_name"]
        set project_dir $build_folder/${_xil_proj_name_}
        set force_flag [expr {[dict get $proj_dict force] ? "-force" : ""}]

        create_project $force_flag ${_xil_proj_name_} $origin_dir/$project_dir -part [dict get $proj_dict "proj_part"]
        # Set the directory path for the new project
        set proj_dir [get_property directory [current_project]]

        # Set project properties
        set obj [current_project]

        # Add properties
        set proj_board_part [dict get $proj_dict "proj_board_part"]
        if {$proj_board_part != ""} {
            set_property -name "board_part" -value $proj_board_part -objects $obj
        }
        set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
        set_property -name "simulator_language" -value "Mixed" -objects $obj
        set_property -name "source_mgmt_mode" -value "DisplayOnly" -objects $obj
        set_property -name "target_language" -value "Verilog" -objects $obj
    }

    # Function to create source filesets with named arguments
    proc create_src_filesets {args} {
        # Define default values for arguments
        array set argValues {
            -base_folder ""
            -target_folder ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        if {$argValues(-base_folder) eq ""} {
            set base_dir $origin_dir
        } else {
            set base_dir [file normalize $argValues(-base_folder)]
        }

        # Create 'sources_1' fileset (if not found)
        if {[string equal [get_filesets -quiet sources_1] ""]} {
            create_fileset -srcset sources_1
        }
        set obj [get_filesets sources_1]
        set src_dir [dict get $proj_dict "proj_src"]
        set target_src_dir "$base_dir/$src_dir"
        if {$argValues(-target_folder) ne ""} {
            set target_src_dir "$base_dir/$src_dir/$argValues(-target_folder)"
        }

        if {[file exists "$target_src_dir"]} {
            add_files -fileset $obj "$target_src_dir"
        }
    }

    # Function to set the project ip_repo folder with named arguments
    proc create_ip_repo_path {args} {
        # Define default values for arguments
        array set argValues {
            -base_folder ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        if {$argValues(-base_folder) eq ""} {
            set base_dir $origin_dir
        } else {
            set base_dir [file normalize $argValues(-base_folder)]
        }

        set ip_repo_dir [dict get $proj_dict "proj_ip_repo"]
        set obj [get_filesets sources_1]
        if {[file exists "$base_dir/$ip_repo_dir"]} {
            set_property "ip_repo_paths" "[file normalize "$base_dir/$ip_repo_dir"]" $obj
            # Rebuild user ip_repo's index before adding any source files
            update_ip_catalog -rebuild
        }
    }

    # Function to create constraint filesets with named arguments
    proc create_constr_filesets {args} {
        # Define default values for arguments
        array set argValues {
            -base_folder ""
            -target_folder ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        if {$argValues(-base_folder) eq ""} {
            set base_dir $origin_dir
        } else {
            set base_dir [file normalize $argValues(-base_folder)]
        }

        # Create 'constrs_1' fileset (if not found)
        if {[string equal [get_filesets -quiet constrs_1] ""]} {
            create_fileset -constrset constrs_1
        }
        # Set 'constrs_1' fileset object
        set obj [get_filesets constrs_1]

        set constr_dir [dict get $proj_dict "proj_constr"]
        set target_constr_dir "$base_dir/$constr_dir"
        if {$argValues(-target_folder) ne ""} {
            set target_constr_dir "$base_dir/$constr_dir/$argValues(-target_folder)"
        }

        set fileList [glob -nocomplain -type f [file join $target_constr_dir *]]
        set constr_files [list]

        foreach file $fileList {
            set extension [file extension $file]
            if {$extension eq ".tcl" || $extension eq ".xdc"} {
                lappend constr_files $file
            }
        }

        foreach file $constr_files {
            set obj [get_filesets constrs_1]
            set file_added [add_files -norecurse -fileset $obj [list $file]]

            if {[file extension $file] eq ".tcl"} {
                set file_obj [lindex $file_added 0]
                set_property -name "file_type" -value "TCL" -objects $file_obj
                # Remove unmanaged Tcl files from synthesis simulation
                set_property USED_IN_SYNTHESIS  false [get_files $file]
                set_property USED_IN_SIMULATION false [get_files $file]
            }
        }
    }

    # Function to create simulation filesets with named arguments
    proc create_sim_filesets {args} {
        # Define default values for arguments
        array set argValues {
            -base_folder ""
            -target_folder ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        if {$argValues(-base_folder) eq ""} {
            set base_dir $origin_dir
        } else {
            set base_dir [file normalize $argValues(-base_folder)]
        }

        # Create 'sim_1' fileset (if not found)
        if {[string equal [get_filesets -quiet sim_1] ""]} {
            create_fileset -simset sim_1
        }

        set obj [get_filesets sim_1]
        set sim_dir [dict get $proj_dict "proj_sim"]
        set target_sim_dir "$base_dir/$sim_dir"
        if {$argValues(-target_folder) ne ""} {
            set target_sim_dir "$base_dir/$sim_dir/$argValues(-target_folder)"
        }

        if {[file exists "$target_sim_dir"]} {
            add_files -fileset $obj "$target_sim_dir"
        }
    }

    # Function to create block design and set file properties with named arguments
    proc create_block_design {args} {
        # Define default values for arguments
        array set argValues {
            -bd_file ""
            -design_name ""
            -validate false
            -base_folder ""
            -target_folder ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        if {$argValues(-base_folder) eq ""} {
            set base_dir $origin_dir
        } else {
            set base_dir [file normalize $argValues(-base_folder)]
        }

        # Create block design
        create_bd_design $argValues(-design_name)
        current_bd_design $argValues(-design_name)

        set bd_dir [dict get $proj_dict "proj_bd"]
        set target_bd_dir "$base_dir/$bd_dir"
        if {$argValues(-target_folder) ne ""} {
            set target_bd_dir "$base_dir/$bd_dir/$argValues(-target_folder)"
        }

        if {[file exists "$target_bd_dir/$argValues(-bd_file).tcl"]} {
            source -notrace "$target_bd_dir/$argValues(-bd_file).tcl"
            create_root_design ""
        } else {
            error "Could not source block design file $target_bd_dir/$argValues(-bd_file).tcl"
        }

        if {$argValues(-validate)} {
            validate_bd_design
        }

        save_bd_design
    }

    # Function to create the block design wrapper with named arguments
    proc create_bd_wrapper {args} {
        # Define default values for arguments
        array set argValues {
            -bd_name ""
            -is_top false
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse "$argValues(-bd_name).bd"] -top]
        add_files -norecurse -fileset sources_1 $wrapper_path

        # Set 'sources_1' fileset file properties for local files
        set file "$argValues(-bd_name)/$argValues(-bd_name).bd"
        set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
        set_property -name "registered_with_manager" -value "1" -objects $file_obj

        # Set 'sources_1' fileset properties
        set obj [get_filesets sources_1]
        if { $argValues(-is_top) } {
            set_property -name "top" -value "$argValues(-bd_name)_wrapper" -objects $obj
            set_property -name "top_auto_set" -value "0" -objects $obj
        }
    }

    # Function to set the project top HDL wrapper with named arguments
    proc set_top_wrapper {args} {
        # Define default values for arguments
        array set argValues {
            -file_name ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        # Assume the requested file is already added to 'sources_1' fileset properties
        set obj [get_filesets sources_1]
        set_property -name "top" -value "$argValues(-file_name)" -objects $obj
    }

    # Function to export block design to tcl with named arguments
    proc cleanup_block_design {args} {
        # Define default values for arguments
        array set argValues {
            -bd_name ""
            -prefix ""
            -base_folder ""
            -target_folder ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]

        if {$argValues(-base_folder) eq ""} {
            set base_dir $origin_dir
        } else {
            set base_dir [file normalize $argValues(-base_folder)]
        }

        set bd_dir [dict get $proj_dict "proj_bd"]
        set target_bd_dir "$base_dir/$bd_dir"
        if {$argValues(-target_folder) ne ""} {
            set target_bd_dir "$base_dir/$bd_dir/$argValues(-target_folder)"
        }

        set bd_file "$target_bd_dir/$argValues(-bd_name).tcl"
        set bd_tmp_file "${argValues(-prefix)}_${argValues(-bd_name)}"
        set bd_tmp_addr "$target_bd_dir/$bd_tmp_file.tcl"

        # Read the content of the block design tcl file
        set fp [open $bd_file r]
        set contents [read $fp]
        close $fp

        # Parse the source code into a list of lines
        set code_lines [split $contents \n]

        # Find the index of the "proc create_root_design" procedure
        # Note: This might not work if the format of the exported tcl file changes
        set proc_index [lsearch -glob $code_lines {# DESIGN PROCs}]

        # Find the index of the line that calls the procedure
        set call_index [lsearch -glob $code_lines {# End of create_root_design()}]
        # Extract the lines between the procedure header and the call
        set proc_lines [lrange $code_lines $proc_index $call_index-1]

        # Join the lines back into a single string
        set proc_text [join $proc_lines \n]

        set fp [open $bd_tmp_addr w]
        puts $fp $proc_text
        close $fp

        return $bd_tmp_file
    }


    # -----------------------------------------------------------------------------
    # Synthesis
    # -----------------------------------------------------------------------------
    # Function to set project synthesis with named arguments
    proc set_proj_synthesis {args} {
        # Define default values for arguments
        array set argValues {
            -generic_prop ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        set proj_part [dict get $proj_dict "proj_part"]

        set toolversion [get_toolversion]
        # Flow string
        set flow "Vivado Synthesis $toolversion"

        # Create 'synth_1' run (if not found)
        if {[string equal [get_runs -quiet synth_1] ""]} {
            create_run -name synth_1 -part "$proj_part" -flow $flow -strategy "Vivado Synthesis Defaults" -constrset constrs_1
        } else {
            set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
            set_property flow $flow [get_runs synth_1]
        }
        set obj [get_runs synth_1]
        set_property part "$proj_part" $obj

        if {$argValues(-generic_prop) ne ""} {
            set_property \
                -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
                -value "$argValues(-generic_prop)" \
                -objects [get_runs synth_1]
        }

        # set the current synth run
        current_run -synthesis $obj
    }


    # -----------------------------------------------------------------------------
    # Implementation
    # -----------------------------------------------------------------------------
    proc set_proj_implementation {} {
        variable proj_dict
        set proj_part [dict get $proj_dict "proj_part"]

        set toolversion [get_toolversion]
        # Flow string
        set flow "Vivado Implementation $toolversion"

        # Create 'impl_1' run (if not found)
        if {[string equal [get_runs -quiet impl_1] ""]} {
            create_run -name impl_1 -part "$proj_part" -flow $flow -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
        } else {
            set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
            set_property flow $flow [get_runs impl_1]
        }
        set obj [get_runs impl_1]
        set_property part "$proj_part" $obj

        # set the current impl run
        current_run -implementation $obj
    }

    # -----------------------------------------------------------------------------
    # Generate the bitstream
    # -----------------------------------------------------------------------------
    proc set_proj_bitstream {} {
        # Generate the bitstream verify mask file
        set_property STEPS.WRITE_BITSTREAM.ARGS.MASK_FILE true [get_runs impl_1]
    }


    proc build_proj { {synth_prop ""}} {
        set_proj_synthesis -generic_prop $synth_prop
        set_proj_implementation
        set_proj_bitstream
        # Generate the bitstream
        set commandOutput [exec nproc]
        set availableCPUs [string trim $commandOutput]
        launch_runs impl_1 -to_step write_bitstream -jobs $availableCPUs
    }

    # Function to export project bitstream with named arguments
    proc export_proj_bitstream {args} {
        # Define default values for arguments
        array set argValues {
            -destination ""
        }

        # Override default values with any provided arguments
        array set argValues $args

        variable proj_dict
        variable _xil_proj_name_
        set origin_dir [file normalize [dict get $proj_dict "proj_addr"]]
        set build_folder [dict get $proj_dict "proj_build_dir_name"]
        if { ![file exists $argValues(-destination)] } {
            file mkdir $argValues(-destination)
        }
        set top_module_name [get_property top [current_fileset]]

        # Construct the source path pattern
        set source_pattern "${origin_dir}/${build_folder}/${_xil_proj_name_}/${_xil_proj_name_}.runs/impl_1/${top_module_name}.*"

        # Find all files that match the pattern and copy them
        foreach file [glob $source_pattern] {
            file copy -force $file $argValues(-destination)
        }
    }

}

