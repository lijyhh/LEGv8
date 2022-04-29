::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
:: Add all Verilog and System Verilog code file name to vflist.f
::
:: Echo file name to vflist1.f first
DIR *.v *.vh *.sv /B /S > vflist1.f
:: Replace '\' with '\\', and store into a new file vflist.f
python py\file_str_replace.py vflist1.f vflist.f
:: Delete vflist1.f
del /f/s/q  vflist1.f

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
:: ModelSim compile and simulation
::
:: Build ModelSim workspace
vlib work

:: Add header
vlog +incdir+ common.vh 

:: Compile all files in sv mode
vlog -sv -f vflist.f

:::: Simulation
::
:::: IF testbench
::vsim -c -novopt work.inst_mem_tb -do "run -all"
::vsim -c -novopt work.IF_tb -do "run -all"

:::: ID testbench
::vsim -c -novopt work.reg_file_tb -do "run -all"
::vsim -c -novopt work.sign_extend_tb -do "run -all"
::vsim -c -novopt work.ID_tb -do "run -all"

:::: EX testbench
::vsim -c -novopt work.ALU_control_tb -do "run -all"
::vsim -c -novopt work.ALU_tb -do "run -all"
::vsim -c -novopt work.control_tb -do "run -all"
::vsim -c -novopt work.EX_tb -do "run -all"

:::: MEM testbench
::vsim -c -novopt work.data_mem_tb -do "run -all"

:::: WB testbench
::vsim -c -novopt work.write_back_tb -do "run -all"

:: TOP testbench
vsim -c -novopt work.TOP_tb -do "run -all"

::pause
