#~/bin/bash

projName=proj4

machine=$(uname)
alias macCompile='g++-8 -DARRSIZE=$arrsize -o $projName main.cpp simd.p4.cpp -lm -fopenmp'
alias linuxCompile='g++ -DARRSIZE=$arrsize -o $projName main.cpp simd.p4.cpp -lm -fopenmp'

rm output.csv
    for arrsize in 1000 10000 50000 100000 500000 1000000
    do
    printf "Array Size: %s\n" "$arrsize"
    printf "%s," "$arrsize" >> output.csv
    if [ "$machine" = "Darwin" ]; then
        macCompile
    else
        linuxCompile
    fi
    ./"$projName" >> output.csv
    printf "\n" >> output.csv
    done
