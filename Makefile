sim:
	verilator --cc --exe --build --trace-fst -top-module example ./vsrc/example.v ./csrc/main.cpp
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!

include ../Makefile
