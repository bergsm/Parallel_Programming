#~/bin/bash

machine=$(uname)
alias macCompile='g++-9 -DNUM_ELEMENTS=$globalSize -DLOCAL_SIZE=$localSize -o proj5Red main.cpp -Wno-write-strings -lm -framework OpenCL -fopenmp
'
alias linuxCompile='g++ -DNUM_ELEMENTS=$globalSize -DLOCAL_SIZE=$localSize -o proj5Red main.cpp -Wno-write-strings -Wno-format -lm -lOpenCL -fopenmp'

rm outputRed.csv
echo " , 1024, 4096, 16384, 65536, 262144, 1048576, 4194304, 8388608 16777216 33554432" >> outputRed.csv
for localSize in 8 16 32 64 128 256 512 1024
do
    #printf "$globalSize, " >> outputRed.csv
    printf "%s," "$localSize" >> outputRed.csv
    for globalSize in 1024 4096 16384 65536 262144 1048576 4194304 8388608 16777216 33554432
    do
        #printf "Elements: %s, Local Size: %s\n" "$globalSize" "$localSize"
        if [ "$machine" = "Darwin" ]; then
            macCompile
        else
            linuxCompile
        fi
        ./proj5Red >> outputRed.csv
    done
    printf "\n" >> outputRed.csv
done
