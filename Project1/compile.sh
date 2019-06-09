#~/bin/bash

machine=$(uname)
alias macCompile='g++-8 -DNUMT=$threads -DNUMTRIALS=$trials -DLAST=$last -o proj1 main.cpp -lm -fopenmp'
alias linuxCompile='g++ -DNUMT=$threads -DNUMTRIALS=$trials -DLAST=$last -o proj1 main.cpp -lm -fopenmp'
last=0

rm output.csv
echo " , 1, 10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000" >> output.csv

for threads in 1 2 4 6 8 16 32 64 96
do
    printf "$threads, " >> output.csv
    for trials in 1 10 50 100 500 1000 5000 10000 50000 100000 500000 1000000 5000000
    do
        if [ "$threads" -eq "96" ] && [ "$trials" -eq "5000000" ]; then
            last=1
        fi
        if [ "$machine" = "Darwin" ]; then
            macCompile
        else
            linuxCompile
        fi
        ./proj1 >> output.csv
    done
    printf "\n" >> output.csv
done
