"""
    File: random_gen.py
    Description: A python script to generate random data, sort random data, and then write them into two files( one is for random data and another is for sorted random data )
    Version: 1
    NOTE: 
    1. num_data is the number of random data
    2. max_range is the range of random data
    3. sep is the separator of random data, it can be '\n', '\r', '\t' or maybe just ' '
    4. base is the base of random data, it can be 16, 2 and 10, which means HEX, BIN and DEC
    5. SP/X1/X0 are used in LEGv8 processer. SP is the initial value of stack pointer, X1 is the number of data to be sorted and X0 is base address of v
    6. random_data_file and random_data_file_sort are the random data file and sorted random data file respectively

    Developers: Zehua Dong, SIGS, 2022.04.26
    How to use: 
    1. Just change the values of those variables above mentioned
    2. Open your cmd.exe and cd to the root directory of this project, then input 'python py/random_gen.py'
"""

import os  
import random 

num_data = 5
max_range = 10
sep = '\n'
base = 16

# Values in LEGv8 registers
SP = str(1023*8)
X1 = str(num_data)
X0 = str(2*8)


random_data_file = './data/bubble_sort/data_mem.txt'
random_data_file_sort = './data/bubble_sort/data_mem_sort.txt'

# Random data generation
def random_gen():
    r_list=[]     # List of random number
    f = open(random_data_file, 'w')# Read file
    loop_num=num_data    # Loop number, i.e. the number of random data
    while(loop_num):
        n = random.randint(1,max_range)  # Default value range is 1~1000000
        if (n in r_list):
            # If repeated, jump out
            continue
        else:
            r_list.append(n)
            # Write into file, seperate with sep
            if base == 16:
                f.write(str(hex(int(n)))[2:] + sep) 
            elif base == 2:
                f.write(str(bin(int(n)))[2:] + sep) 
            else:
                f.write(str(n) + sep)  
            loop_num = loop_num - 1       # Decreasing number of loop 
    f.close()

# Random data sort
def random_sort():
    f = open(random_data_file, 'r')
    filenum=[]
    for fline in f.readlines():
        if sep in ['\n', '\r']:
            filenum.append(fline)
        else:
            fline=fline.replace(sep," ")
            filenum=fline.split() # Sperate with space
    res=[]
    for i in range(len(filenum)):
        m=int(filenum[i], base) # Convert to int
        res.append(m)     
    res1=quick_sort(res,0,num_data-1) # Quick sort
    f1 = open(random_data_file_sort, 'w')
    for i in range(0,len(res1)):
        if base == 16:
            f1.write(str(hex(int(res1[i])))[2:] + sep) 
        elif base == 2:
            f1.write(str(bin(int(res1[i])))[2:] + sep) 
        else:
            f1.write(str(res1[i]) + sep) # Write into new file
    f.close()

# Quick sort algorithm
# begin is the first index of lists
# end is the last index of lists
def quick_sort(lists, begin, end):
    if begin >= end:
        return lists
    tmp = lists[begin]
    low = begin
    high = end
    while begin < end:
        while begin < end and lists[end] >= tmp:
            end -= 1
        lists[begin] = lists[end]
        while begin < end and lists[begin] <= tmp:
            begin += 1
        lists[end] = lists[begin]
    lists[end] = tmp
    quick_sort(lists, low, begin - 1)
    quick_sort(lists, begin + 1, high)
    return lists

def insert_line(file, line, data):
    fp = open(file)         
    lines = []
    for l in fp:      
        lines.append(l)
    fp.close()
    
    if base == 16:
        lines.insert(line, str(hex(int(data)))[2:] + sep)
    elif base == 2:
        lines.insert(line, str(bin(int(data)))[2:] + sep)
    else:
        lines.insert(line, data) # Insert string in ( line + 1 )
    s = ''.join(lines)
    fp = open(file, 'w')
    fp.write(s)
    fp.close()

random_gen()
random_sort()
insert_line(random_data_file, 0, SP)
insert_line(random_data_file, 1, X1)
insert_line(random_data_file, 2, X0)
insert_line(random_data_file_sort, 0, SP)
insert_line(random_data_file_sort, 1, X1)
insert_line(random_data_file_sort, 2, X0)
print("Done!")
