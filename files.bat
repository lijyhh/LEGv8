DIR *.v *.vh *.sv /B /S > vflist1.f
python F:\Files\lab_2001\Project\batch_files\scripts\py\file_str_replace.py vflist1.f vflist.f
del /f/s/q  vflist1.f

vlib work

vlog +incdir+ common.vh 

vlog -sv -f vflist.f
::vlog -f vflist.f

vsim -c -novopt work.inst_mem_tb -do "run -all"
::vsim -c -novopt work.IF_tb -do "run -all"

::vsim -c -novopt work.reg_file_tb -do "run -all"
::vsim -c -novopt work.sign_extend_tb -do "run -all"
::vsim -c -novopt work.ID_tb -do "run -all"

::vsim -c -novopt work.ALU_control_tb -do "run -all"
::vsim -c -novopt work.ALU_tb -do "run -all"
::vsim -c -novopt work.control_tb -do "run -all"
::vsim -c -novopt work.EX_tb -do "run -all"

::vsim -c -novopt work.data_mem_tb -do "run -all"

::vsim -c -novopt work.write_back_tb -do "run -all"

::vsim -c -novopt work.TOP_tb -do "run -all"

pause
