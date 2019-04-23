#~/bin/bash

machine=$(uname)
alias macCompile='g++-8 -DNUMT=$threads -DNUMNODES=$nodes -DFIRST=$first -o proj2 main.cpp -lm -fopenmp'
alias linuxCompile='g++ -DNUMT=$threads -DNUMNODES=$nodes -DFIRST=$first -o proj2 main.cpp -lm -fopenmp'
first=0

rm output.csv
echo " , 1, 10, 50, 100, 500, 1000, 5000, 10000" >> output.csv
#echo " , 1, 10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000" >> output.csv

for threads in 1 2 4 6 8
do
    printf "$threads, " >> output.csv
    for nodes in 1 10 50 100 500 1000 5000 10000
    #for nodes in 1 10 50 100 500 1000 5000 10000 50000 100000 500000 1000000 5000000
    do
        if [ "$threads" -eq "1" ] && [ "$trials" -eq "1" ]; then
            first=1
        fi
        if [ "$machine" = "Darwin" ]; then
            macCompile
        else
            linuxCompile
        fi
        ./proj2 >> output.csv
    done
    printf "\n" >> output.csv
done
