#~/bin/bash

projName=proj4

machine=$(uname)
alias macCompile='g++-8 -DARRSIZE=$arrsize -DLAST=$last -o $projName simd.p4.cpp -lm -fopenmp'
alias linuxCompile='g++ -DARRSIZE=$arrsize -DLAST=$last -o $projName simd.p4.cpp -lm -fopenmp'
last=0

rm output.csv
echo " , 1000, 10000, 50000, 100000, 500000, 1000000, 2000000, 5000000" >> output.csv
    for arrsize in 1000 10000 50000 100000 500000 1000000 2000000 5000000
    do
    printf "Array Size: %s\n" "$arrsize"
    if [ "$machine" = "Darwin" ]; then
        macCompile
    else
        linuxCompile
    fi
    ./"$projName" >> output.csv
    done
printf "\n" >> output.csv
