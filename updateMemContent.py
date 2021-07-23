#usage python3 script.py hexfile.hex meminputfile.vhd row_start_number row_end_number memoutputfile.vhd
#row numbers are counted so that the first line is the one line number 1 (check text editor that you use)

import sys 


hexFilename = sys.argv[1]
hexFileHandler = open(hexFilename, "r")

memInFilename = sys.argv[2]
memInFileHandler = open(memInFilename, "r")

startingRow = int(sys.argv[3])
endingRow = int(sys.argv[4])

memOutFilename = sys.argv[5]
memOutFileHandler = open(memOutFilename, "w")

littleEndianProgram = []                                      #hexadecimal instructions using little-endian convention
memoryVHDLProgram = []                                        #row associated to little-endian instructions, to be written in the VHDL memory file
memInFileContentList = []
memInFileContentList = memInFileHandler.readlines()           #memory old vhdl file row content in a list
memInFileContentList.insert(0,"")

baseAddress = 0

#filling littleEndianProgram List
for line in hexFileHandler:            
    byteCount = int(line[1:3],16)
    addressOffset = int(line[3:7],16)
    recordType = int(line[7:9],16)
    if recordType == 0:
        for istrStart in range(9,9+byteCount*2,8):  #jump from istruction to the next one
            littleEndianProgram.append(line[istrStart:istrStart+8]) #add the current istruction to the program

#filling memoryVHDLProgram List
for index in range(len(littleEndianProgram)):
    memoryVHDLProgram.append(str(index) + " => x\"" + littleEndianProgram[index] + "\",\n")


#WRITING THE NEW VHDL MEMORY FILE 

#copying before-memory content part of the VHDL old file in the new one
for rowIndex in range(1,startingRow):   #starting row is excluded from the range
    memOutFileHandler.write(memInFileContentList[rowIndex])

memOutFileHandler.write("    signal memory_space: memory_space_t := (\n");

#writing new memory content
for row in memoryVHDLProgram:
    memOutFileHandler.write(row)

memOutFileHandler.write("others => (others => '1')\n");
memOutFileHandler.write("    );\n");

#copying after-memory content part of the VHDL old file in the new one
for rowIndex in range(endingRow+1,len(memInFileContentList)):   #starting row is excluded from the range
    memOutFileHandler.write(memInFileContentList[rowIndex])