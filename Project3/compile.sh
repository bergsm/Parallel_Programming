#~/bin/bash

projName=proj3

machine=$(uname)
alias macCompile='g++-8 -DNUMT=$threads -DNUMNODES=$nodes -DLAST=$last -o $projName main.cpp -lm -fopenmp'
alias linuxCompile='g++ -DNUMT=$threads -DNUMNODES=$nodes -DLAST=$last -o $projName main.cpp -lm -fopenmp'
last=0

rm output.csv
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
        ./"$projName" >> output.csv
    done
    printf "\n" >> output.csv
done
