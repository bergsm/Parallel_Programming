#~/bin/bash

machine=$(uname)
alias macCompile='g++-9 -DNUM_ELEMENTS=$globalSize -DLOCAL_SIZE=$localSize -o proj5 main.cpp -Wno-write-strings -lm -framework OpenCL -fopenmp
'
alias linuxCompile='g++ -DNUM_ELEMENTS=$globalSize -DLOCAL_SIZE=$localSize -o proj5 main.cpp -Wno-write-strings -lm -lOpenCL -fopenmp'

rm output.csv
echo " , 1024, 4096, 16384, 65536, 262144, 1048576, 4194304, 8388608" >> output.csv
for clFile in "arrMult.cl" "arrMultAdd.cl"
do
    #printf "clFile: %s\n" "$clFile" >> output.csv
    for localSize in 8 16 32 64 128 256 512
    do
        #printf "$globalSize, " >> output.csv
        printf "%s," "$localSize" >> output.csv
        for globalSize in 1024 4096 16384 65536 262144 1048576 4194304 8388608
        do
            #printf "Elements: %s, Local Size: %s\n" "$globalSize" "$localSize"
            if [ "$machine" = "Darwin" ]; then
                macCompile
            else
                linuxCompile
            fi
            ./proj5 >> output.csv
        done
        printf "\n" >> output.csv
    done
done
