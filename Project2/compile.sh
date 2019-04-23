#~/bin/bash

machine=$(uname)
alias macCompile='g++-8 -DNUMT=$threads -DNUMNODES=$nodes -DLAST=$last -o proj2 main.cpp -lm -fopenmp'
alias linuxCompile='g++ -DNUMT=$threads -DNUMNODES=$nodes -DLAST=$last -o proj2 main.cpp -lm -fopenmp'
last=0

rm output.csv
rm volume.csv
echo " , 4, 10, 50, 100, 250, 500, 1000, 2500, 5000, 7500, 10000" >> output.csv

for threads in 1 2 4 6 8 12 16 24
do
    if [ "$threads" -eq "24" ]; then
        last=1
    fi
    printf "$threads, " >> output.csv
    for nodes in 4 10 50 100 250 500 1000 2500 5000 7500 10000
    do
        printf "Threads: %s, Nodes: %s\n" "$threads" "$nodes"
        if [ "$machine" = "Darwin" ]; then
            macCompile
        else
            linuxCompile
        fi
        ./proj2 >> output.csv
    done
    printf "\n" >> output.csv
done
