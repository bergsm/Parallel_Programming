#~/bin/bash

rm output.txt

for t in 1 2 4 6 8
    do
	    g++-8 -DNUMT=$t -o proj1 main.cpp -lm -fopenmp
		#g++ -DNUMT=1 -o proj0 main.cpp -lm -fopenmp
	    ./proj1 >> output.txt
    done
