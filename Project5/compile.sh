#~/bin/bash

machine=$(uname)
alias macCompile='g++-9 -DNUM_ELEMENTS=$elements -DLOCAL_SIZE=$localSize -o proj5 main.cpp -Wno-write-strings -lm -framework OpenCL -fopenmp
'
alias linuxCompile='g++ -DNUM_ELEMENTS=$elements -DLOCAL_SIZE=$localSize -o proj5 main.cpp -Wno-write-strings -lm -lOpenCL -fopenmp'

rm output.csv
echo " , 4, 10, 50, 100, 250, 500, 1000, 2500, 5000, 7500, 10000" >> output.csv
for clFile in "arrMult.cl" "arrMultAdd.cl"
do
    printf "clFile: %s\n" "$clFile" >> output.csv
    for elements in 1024 4096 16384 65536 262144 1048576 4194304 8388608
    do
        printf "$elements, " >> output.csv
        for localSize in 8 16 32 64 128 256 512
        do
            printf "Elements: %s, Local Size: %s\n" "$elements" "$localSize"
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
