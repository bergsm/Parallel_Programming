#~/bin/bash

#TODO compile for CUDA
machine=$(uname)
alias macCompile='g++-8 -DBLOCKSIZE=$blocksize -DNUMTRIALS=$trials -DLAST=$last -o proj6 main.cpp -lm -fopenmp'
alias linuxCompile='g++ -DBLOCKSIZE=$blocksize -DNUMTRIALS=$trials -DLAST=$last -o proj6 main.cpp -lm -fopenmp'
last=0

rm output.csv
echo " , 1, 10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000" >> output.csv

for blocksize in 16 32 64
do
    printf "$blocksize, " >> output.csv
    for trials in 16000 32000 64000 128000 256000 512000
    do
        if [ "$blocksize" -eq "64" ] && [ "$trials" -eq "512000" ]; then
            last=1
        fi
        if [ "$machine" = "Darwin" ]; then
            macCompile
        else
            linuxCompile
        fi
        ./proj6 >> output.csv
    done
    printf "\n" >> output.csv
done
