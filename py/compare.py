import os  

# random_data_file_tb_sort = './data/bubble_sort/SingleCycle/data_mem_tb_sorted.txt'
# random_data_file_py_sort = './data/bubble_sort/SingleCycle/data_mem_py_sorted.txt'

random_data_file_tb_sort = './data/bubble_sort/Pipeline/data_mem_tb_sorted.txt'
random_data_file_py_sort = './data/bubble_sort/Pipeline/data_mem_py_sorted.txt'

def cmp_file(f1, f2):
    st1 = os.stat(f1)
    st2 = os.stat(f2)

    # Compare size of these two files
    if st1.st_size != st2.st_size:
        return False

    bufsize = 8*1024
    with open(f1, 'rb') as fp1, open(f2, 'rb') as fp2:
        while True:
            b1 = fp1.read(bufsize)  # Read the data of the specified size for comparison
            b2 = fp2.read(bufsize)
            if b1 != b2:
                return False
            if not b1:
                return True

print("Compare Done! Sort " + str(cmp_file(random_data_file_tb_sort, random_data_file_py_sort)) + "!")

