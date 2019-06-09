#~/bin/bash

machine=$(uname)
#alias macCompile='g++-9 -DNUM_PARTICLES=$particleSize -o proj7 main.cpp -Wno-write-strings -lm -framework OpenCL -fopenmp'
alias macCompile='g++-9 -o proj7 main.cpp -Wno-write-strings -lm -framework OpenGL -framework OpenCL -framework GLUI -framework GLUT -fopenmp'
alias linuxCompile='g++ -DNUM_PARTICLES=$particleSize -o proj5 main.cpp -Wno-write-strings -Wno-format -lm -lOpenCL -fopenmp'

rm output.csv
#for particleSize in 1024 4096 16384 65536 262144 1048576 4194304
#do
    printf "$particleSize, " >> output.csv
    #printf "Elements: %s, Local Size: %s\n" "$particleSize" "$localSize"
    if [ "$machine" = "Darwin" ]; then
        macCompile
    else
        linuxCompile
    fi
    ./proj7 >> output.csv
#done
#printf "\n" >> output.csv