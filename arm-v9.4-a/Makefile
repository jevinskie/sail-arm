LEM=lem
CC=gcc

# Attempt to work with either sail from opam or built from repo in SAIL_DIR
ifneq ($(SAIL_DIR),)
# Use sail repo in SAIL_DIR
SAIL:=$(SAIL_DIR)/sail
export SAIL_DIR
else
# Use sail from opam package
SAIL_DIR:=$(shell opam config var sail:share)
SAIL:=sail
endif

# Check if CC is Clang or GCC
CC_VERSION := $(shell $(CC) --version 2>/dev/null)

IS_CLANG := $(findstring clang, $(CC_VERSION))
IS_GCC := $(findstring GCC, $(CC_VERSION))

ifeq ($(IS_CLANG),clang)
    $(info Compiler is Clang)
    CFLAGS += -fbracket-depth=4096
else ifeq ($(IS_GCC),GCC)
    $(info Compiler is GCC)
else
    $(info Compiler is not recognized or not set)
endif

# Check if Homebrew is installed
HOMEBREW := $(shell command -v brew 2>/dev/null)

# Set *FLAGS for GMP only if Homebrew is installed and not empty
ifeq ($(GMP_PREFIX_DIR),)
    ifneq ($(HOMEBREW),)
        GMP_PREFIX_DIR := $(shell brew --prefix gmp 2>/dev/null)
        ifeq ($(wildcard $(GMP_PREFIX_DIR)),)
            $(error Homebrew found but gmp not installed. Run 'brew install gmp')
        endif
    endif
else
    ifeq ($(wildcard $(GMP_PREFIX_DIR)),)
        $(error Manually specified GMP from GMP_PREFIX_DIR at '$(GMP_PREFIX_DIR)' doesn't exist)
    endif
endif
ifneq ($(GMP_PREFIX_DIR),)
    GMP_INCLUDE_DIR := $(GMP_PREFIX_DIR)/include
    GMP_LIB_DIR := $(GMP_PREFIX_DIR)/lib

    ifneq ($(wildcard $(GMP_INCLUDE_DIR)),)
        GMP_CFLAGS += -I $(GMP_INCLUDE_DIR)
    else
        $(error GMP is installed but include dir is missing at: $(GMP_INCLUDE_DIR))
    endif
    ifneq ($(wildcard $(GMP_LIB_DIR)/libgmp.a),)
        GMP_LDFLAGS += $(GMP_LIB_DIR)/libgmp.a
    else ifneq ($(wildcard $(GMP_LIB_DIR)),)
        GMP_LDFLAGS += -L $(GMP_LIB_DIR) -lgmp
    else
        $(error GMP is installed but lib dir is missing at: $(GMP_LIB_DIR))
    endif
else

endif

CFLAGS += -O3 -flto=full
LDFLAGS += -fvisibility=hidden -fvisibility-inlines-hidden -fvisibility-inlines-hidden-static-local-var


ISLA_SAIL=isla-sail
ISLA_PREPROCESS=isla-preprocess
ISLA_PREPROCESS_CONFIG=../../isla/configs/armv9p4.toml

DEVICES=devices.sail
DEVICES_PATH=src/$(DEVICES)

SAIL_SRCS=src/prelude.sail src/decode_start.sail src/builtins.sail src/v8_base.sail src/sysregs_autogen.sail src/sysregs.sail src/instrs64.sail src/instrs64_sve.sail src/instrs64_sme.sail src/instrs32.sail src/interrupts.sail src/reset.sail src/fetch.sail src/interface.sail $(DEVICES_PATH) src/impdefs.sail src/mem.sail src/decode_end.sail src/map_clauses.sail src/event_clauses.sail src/stubs.sail
SAIL_MAIN=src/elfmain.sail
ISLA_MAIN=src/isla_main.sail
ISLA_SPLICE=src/isla_splice.sail
LEM_SPLICES=$(wildcard src/lem-patches/*.sail)
SAIL_FLAGS = -verbose 1 -memo_z3
# Extra monomorphisation splits
SAIL_LEM_FLAGS = $(file < sail-lem-flags)
SAIL_C_FLAGS = -O -Oconstant_fold -c_specialize -c_preserve -static -grouped_regstate -const_prop_mutrec -auto_mono -mono_rewrites

$(info SAIL_C_FLAGS: $(SAIL_C_FLAGS))

all: lem.stamp isabelle.stamp coq.stamp

.PHONY: all clean interactive gen_c gen_isabelle

lem lem.stamp: $(SAIL_SRCS) $(LEM_SPLICES) lem/prelude.lem
	mkdir -p isabelle
	$(SAIL) -dprofile -grouped_regstate \
	        -lem -lem_output_dir lem -isa_output_dir isabelle -o armv9 -lem_lib Prelude \
	        -lem_mwords -mono_rewrites -auto_mono -undefined_gen \
	        $(foreach splice,$(LEM_SPLICES),-splice $(splice)) \
	        $(SAIL_SRCS) $(SAIL_LEM_FLAGS) $(SAIL_FLAGS)
	sed -i '/open import Sail2_monadic_combinators/a open import Prelude' lem/armv9_types.lem
	sed -i -f src/lem-patches/ldr1ron_ty0_fixup.sed lem/armv9.lem
	touch lem.stamp

lem/prelude.lem: src/lem-patches/prelude.lem
	mkdir -p lem
	cp $^ lem

gen_isabelle isabelle isabelle.stamp: lem.stamp
	mkdir -p isabelle
	$(LEM) -isa -outdir isabelle -lib Sail=$(SAIL_DIR)/src/gen_lib \
	    lem/prelude.lem lem/armv9_types.lem lem/armv9.lem
	touch isabelle.stamp

gen_coq coq coq.stamp: $(SAIL_SRCS) src/coq_termination.sail
	$(SAIL) -dprofile \
	        -coq -dcoq_undef_axioms \
	        -coq_output_dir coq -o armv9 -coq_lib arm_extras \
	        -undefined_gen \
	        $(SAIL_SRCS) $(SAIL_FLAGS) \
	        src/coq_termination.sail
	touch coq.stamp

c/armv9.c: $(SAIL_SRCS) $(SAIL_MAIN)
	mkdir -p c
	$(SAIL) -dprofile $(SAIL_FLAGS) -c $(SAIL_C_FLAGS) $(SAIL_SRCS) $(SAIL_MAIN) > c/armv9.c.temp
	mv c/armv9.c.temp c/armv9.c

gen_c c c.stamp: $(addsuffix .o,$(basename $(addprefix c/,$(notdir $(wildcard $(SAIL_DIR)/lib/*.c))))) c/armv9
	touch c.stamp

c/armv9: $(addsuffix .o,$(basename $(addprefix c/,$(notdir $(wildcard $(SAIL_DIR)/lib/*.c))))) c/armv9.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(GMP_LDFLAGS) -lz $^ -o $@

c/armv9.o: c/armv9.c
	$(CC) $(CFLAGS) $(GMP_CFLAGS) -I $(SAIL_DIR)/lib/ $^ -c -o $@

c/%.o: $(SAIL_DIR)/lib/%.c
	mkdir -p c
	$(CC) $(CFLAGS) $(GMP_CFLAGS) -DHAVE_SETCONFIG $^ -c -o $@

gen_ir ir/armv9.ir: $(SAIL_SRCS) $(SAIL_MAIN) $(ISLA_MAIN) $(ISLA_SPLICE)
	mkdir -p ir
	$(ISLA_SAIL) -v 1 -mono_rewrites $(SAIL_SRCS) $(SAIL_MAIN) $(ISLA_MAIN) -splice $(ISLA_SPLICE) -o ir/armv9

gen_irx ir/armv9.irx: ir/armv9.ir
	$(ISLA_PREPROCESS) -A ir/armv9.ir -C $(ISLA_PREPROCESS_CONFIG) -o ir/armv9

interactive:
	$(SAIL) -i $(SAIL_SRCS) $(SAIL_FLAGS) \
	        src/coq_termination.sail

clean:
	rm -f lem.stamp lem/arm.lem lem/arm_types.lem
	rm -f isabelle.stamp isabelle/Arm_lemmas.thy isabelle/Arm.thy isabelle/Arm_types.thy \
	  isabelle/Prelude.thy isabelle/ArmAuxiliary.thy
	rm -f coq.stamp coq/{arm_extras,armv9,armv9_types}.{v,vo,vok,vos,glob}
	rm -f ir/armv9.ir
	rm -rf c/
