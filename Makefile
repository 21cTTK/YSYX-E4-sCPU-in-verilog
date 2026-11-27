TOP = sCPU
export NVBOARD_HOME ?= $(abspath ../nvboard)

BUILD = build
BIN = $(BUILD)/$(TOP)
BIND = $(BUILD)/auto_bind.cpp
VSRC = $(wildcard vsrc/*.v)

board: $(BIN)

sim: board
	$(call git_commit, "sim VSRC") # DO NOT REMOVE THIS LINE!!!

run: board
	./$(BIN)

include $(NVBOARD_HOME)/scripts/nvboard.mk
include ../Makefile

$(BIND): $(TOP).nxdc $(NVBOARD_HOME)/scripts/auto_pin_bind.py $(NVBOARD_HOME)/board/N4
	@mkdir -p $(BUILD)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $< $@

$(BIN): $(VSRC) csrc/main.cpp $(BIND) $(NVBOARD_ARCHIVE) Makefile
	verilator --cc --exe --build --top-module $(TOP) --Mdir $(BUILD)/obj_dir \
		$(VSRC) $(abspath csrc/main.cpp $(BIND) $(NVBOARD_ARCHIVE)) \
		-CFLAGS "$(CXXFLAGS) $(addprefix -I,$(INC_PATH))" -LDFLAGS "$(LDFLAGS)" \
		-o $(abspath $@)

.PHONY: board sim run

