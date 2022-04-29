import sys

fp = open(sys.argv[2],'w') # Open file test2.txt
lines = open(sys.argv[1]).readlines() # Read each line
for s in lines:
    fp.write( s.replace("\\","\\\\")) # Replace '\\' to '\\\\'
fp.close() # Close file   
