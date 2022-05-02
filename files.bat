@echo off
cd /d %~dp0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
:: Add all Verilog and System Verilog code file name to vflist.f
::
:: Echo file name to vflist1.f first
dir *.v *.vh *.sv /b /s > vflist1.f

:: Replace '\' with '\\', and store into a new file vflist.f
python py\file_str_replace.py vflist1.f vflist.f

:: Delete vflist1.f
echo.
del /f /s /q  vflist1.f
echo.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
:: ModelSim compile and simulation
::
:: Build ModelSim workspace
echo Building ModelSim workspace...
vlib work
echo.

:: Add header
echo Adding header...
vlog +incdir+ common.vh
echo.

:: Compile all files in sv mode
echo Compiling...
vlog -sv -f vflist.f
echo.

:::: Simulation
::
echo Simulating...
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
::vsim -c -novopt work.EX_tb -do "run -all"

:::: MEM testbench
::sim -c -novopt work.data_mem_tb -do "run -all"

:::: WB testbench
::vsim -c -novopt work.write_back_tb -do "run -all"

:::: TOP testbench
::vsim -c -novopt work.control_tb -do "run -all"
vsim -c -novopt work.TOP_tb -do "run -all"
echo.

echo All done!
echo.
::pause
