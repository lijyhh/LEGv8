import sys

fp = open(sys.argv[2],'w') #打开你要写得文件test2.txt
lines = open(sys.argv[1]).readlines() #打开文件，读入每一行
for s in lines:
    #fp.write( s.replace('!!!','\n\n\n').replace('!!','\n'))  # replace是替换，write是写入
    fp.write( s.replace("\\","\\\\"))  # replace是替换，write是写入
fp.close() # 关闭文件   
