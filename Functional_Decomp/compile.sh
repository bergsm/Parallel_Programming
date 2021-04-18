#~/bin/bash

projName=proj3

machine=$(uname)
alias macCompile='g++-8 -o $projName main.cpp -lm -fopenmp'
alias linuxCompile='g++ -o $projName main.cpp -lm -fopenmp'

rm output.csv
if [ "$machine" = "Darwin" ]; then
    macCompile
else
    linuxCompile
fi
./"$projName" >> output.csv
