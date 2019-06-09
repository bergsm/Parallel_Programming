#~/bin/bash

export NVCC=/usr/local/cuda-10.1/bin/nvcc

machine=$(uname)
alias macCompile='$NVCC -DBLOCKSIZE=$blocksize -DSIZE=$trials -DLAST=$last -o proj6 ./CudaMonteCarlo/monteCarlo.cu'
alias linuxCompile='$NVCC -DBLOCKSIZE=$blocksize -DSIZE=$trials -DLAST=$last -o proj6 ./CudaMonteCarlo/monteCarlo.cu'
last=0

rm output.csv
echo " ,16000, 32000, 64000, 128000, 256000, 512000" >> output.csv

for blocksize in 16 32 64 96 128
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
