#~/bin/bash

#TODO use uname to distinguish machines
#TODO use variables for compile commands

rm output.txt
for trials in 1 10 50 100 500 1000 5000 10000 50000 1000000 500000 1000000 5000000
do
    for threads in 1 2 4 6 8
    do
        #g++-8 -DNUMT=$t -o proj1 main.cpp -lm -fopenmp
        g++ -DNUMT=$threads -DNUMTRIALS=$trials -o proj1 main.cpp -lm -fopenmp
        ./proj1 >> output.txt
    done
done
