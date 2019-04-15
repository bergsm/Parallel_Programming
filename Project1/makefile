all:
	#TODO conditional for machine
	#TODO for loop and out put to .csv file?]
	g++-8 -DNUMT=1 -o proj1 main.cpp -lm -fopenmp
	#g++ -DNUMT=1 -o proj0 main.cpp -lm -fopenmp
	./proj1
	g++-8 -DNUMT=4 -o proj1 main.cpp -lm -fopenmp
	#g++ -DNUMT=4 -o proj0 main.cpp -lm -fopenmp
	./proj1
clean:
	rm proj*
