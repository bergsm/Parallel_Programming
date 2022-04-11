#!/bin/sh

machine=$(uname)
alias macCompile='g++-9 -DNUM_PARTICLES=$particleSize -o proj7 main.cpp -Wno-write-strings -Wno-deprecated-declarations -lm -framework OpenGL -framework OpenCL -framework GLUI -framework GLUT -fopenmp'
#alias macCompile='g++-9 -o proj7 main.cpp -Wno-write-strings -Wno-deprecated-declarations -lm -framework OpenGL -framework OpenCL -framework GLUI -framework GLUT -fopenmp'
alias linuxCompile='g++ -DNUM_PARTICLES=$particleSize -o proj7 main.cpp -Wno-write-strings -Wno-format -lm -lGL -lGLU -lGLEW -lglui -lOpenCL -lglut -fopenmp'

rm output.csv
for particleSize in 65536 262144 1048576 2097152 4194304 8388608
do
    #printf "$particleSize, " >> output.csv
    #printf "Elements: %s, Local Size: %s\n" "$particleSize" "$localSize"
    if [ "$machine" = "Darwin" ]; then
        macCompile
    else
        linuxCompile
    fi
    ./proj7 >> output.csv
    #PID=$!
    #sleep 30s
    #kill $PID
done
#printf "\n" >> output.csv
