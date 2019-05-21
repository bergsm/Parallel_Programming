#~/bin/bash

machine=$(uname)
alias macCompile='g++-9 -DNUM_ELEMENTS=$elements -DLOCAL_SIZE=$localSize -o proj5Red mainRed.cpp -Wno-write-strings -lm -framework OpenCL -fopenmp
'
alias linuxCompile='g++ -DNUM_ELEMENTS=$elements -DLOCAL_SIZE=$localSize -o proj5Red mainRed.cpp -Wno-write-strings -lm -lOpenCL -fopenmp'

rm outputRed.csv
echo " , 4, 10, 50, 100, 250, 500, 1000, 2500, 5000, 7500, 10000" >> outputRed.csv
for elements in 1 2 4 6 8 12 16 24
do
    printf "$elements, " >> outputRed.csv
    for localSize in 4 10 50 100 250 500 1000 2500 5000 7500 10000
    do
        printf "Threads: %s, Nodes: %s\n" "$elements" "$localSize"
        if [ "$machine" = "Darwin" ]; then
            macCompile
        else
            linuxCompile
        fi
        ./proj5Red >> outputRed.csv
    done
    printf "\n" >> outputRed.csv
done
