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

ISLA_SAIL=isla-sail
ISLA_PREPROCESS=isla-preprocess
ISLA_PREPROCESS_CONFIG=../../isla/configs/armv9p4.toml

DEVICES=devices.sail
DEVICES_LEM=$(addsuffix .lem,$(basename $(DEVICES)))
DEVICES_PATH=src/$(DEVICES)

SAIL_SRCS=src/prelude.sail src/decode_start.sail src/builtins.sail src/v8_base.sail src/stubs.sail src/interrupts.sail src/interface.sail $(DEVICES_PATH) src/impdefs.sail src/mem.sail src/sysregs_autogen.sail src/sysregs.sail src/reset.sail src/instrs32.sail src/instrs64.sail src/instrs64_sve.sail src/instrs64_sme.sail src/decode_end.sail src/fetch.sail src/map_clauses.sail src/event_clauses.sail
SAIL_MAIN=src/elfmain.sail
ISLA_MAIN=src/isla_main.sail
ISLA_SPLICE=src/isla_splice.sail
LEM_SPLICES=$(wildcard src/lem-patches/*.sail)
SAIL_FLAGS = -verbose 1 -memo_z3
SAIL_C_FLAGS = -O -Oconstant-fold -Ofast-undefined -Oaarch64-fast -c-specialize -c-preserve -c-fold-unit -static -grouped-regstate -const-prop-mutrec -auto-mono -mono_rewrites
# Extra monomorphisation splits
SAIL_LEM_FLAGS = $(file < sail-lem-flags)

<<<<<<< HEAD
$(info SAIL_FLAGS: $(SAIL_FLAGS))
$(info SAIL_C_FLAGS: $(SAIL_C_FLAGS))
$(info SAIL_LEM_FLAGS: $(SAIL_LEM_FLAGS))

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

CFLAGS += -O1
LDFLAGS += -fvisibility=hidden -fvisibility-inlines-hidden -fvisibility-inlines-hidden-static-local-var


||||||| 182b439
=======
LEM_BASE_FILES=armv9_types.lem builtins.lem decode_start.lem prelude.lem v8_base.lem
LEM_SYSTEM_FILES=impdefs.lem interface.lem interrupts.lem $(DEVICES_LEM) reset.lem stubs.lem sysregs_autogen.lem sysregs.lem
LEM_INSTRS_FILES=instrs32.lem instrs64.lem
LEM_VECTOR_INSTRS_FILES=instrs64_sme.lem instrs64_sve.lem
LEM_LIBS=-lib Sail=$(SAIL_DIR)/src/gen_lib -lib Sail-Armv9-Base=lem/base -lib Sail-Armv9-System=lem/system -lib Sail-Armv9-Instrs=lem/instrs -lib Sail-Armv9-Vector-Instrs=lem/vector_instrs

>>>>>>> master
all: lem.stamp isabelle.stamp coq.stamp

.PHONY: all clean interactive gen_c gen_isabelle

lem lem.stamp: $(SAIL_SRCS) $(LEM_SPLICES) lem/base/extra_defs.lem src/termination_measures.sail src/lem-patches/Feature.patch
	mkdir -p isabelle
<<<<<<< HEAD
	$(SAIL) -dprofile -grouped_regstate \
	        -lem -lem_output_dir lem -isa_output_dir isabelle -o armv9 -lem_lib Prelude \
||||||| 182b439
	$(SAIL) -dprofile -verbose 1 -memo_z3 -grouped_regstate \
	        -lem -lem_output_dir lem -isa_output_dir isabelle -o armv9 -lem_lib Prelude \
=======
	$(SAIL) -dprofile -verbose 1 -memo_z3 -grouped_regstate -lem_split_files \
	        -lem -lem_output_dir lem -isa_output_dir isabelle -o armv9 -lem_lib Extra_defs \
>>>>>>> master
	        -lem_mwords -mono_rewrites -auto_mono -undefined_gen \
	        $(foreach splice,$(LEM_SPLICES),-splice $(splice)) \
	        $(SAIL_SRCS) src/termination_measures.sail $(SAIL_LEM_FLAGS) $(SAIL_FLAGS)
	sed -i '/open import Sail2_monadic_combinators/a open import Extra_defs' lem/armv9_types.lem
	sed -i -f src/lem-patches/ldr1ron_ty0_fixup.sed lem/instrs64_sve.lem
	patch -p0 < src/lem-patches/Feature.patch
	mkdir -p lem/base lem/system lem/instrs lem/vector_instrs
	mv $(addprefix lem/,$(LEM_BASE_FILES)) lem/base
	mv $(addprefix lem/,$(LEM_SYSTEM_FILES)) lem/system
	mv $(addprefix lem/,$(LEM_INSTRS_FILES)) lem/instrs
	mv $(addprefix lem/,$(LEM_VECTOR_INSTRS_FILES)) lem/vector_instrs
	touch lem.stamp

lem/base/extra_defs.lem: src/lem-patches/extra_defs.lem
	mkdir -p lem/base
	cp $^ lem/base

gen_isabelle isabelle isabelle.stamp: lem.stamp
	mkdir -p isabelle/base isabelle/system isabelle/instrs isabelle/vector_instrs
	$(LEM) -isa $(LEM_LIBS) -outdir isabelle/base lem/base/*.lem
	$(LEM) -isa $(LEM_LIBS) -outdir isabelle/system lem/system/*.lem
	$(LEM) -isa $(LEM_LIBS) -outdir isabelle/instrs lem/instrs/*.lem
	$(LEM) -isa $(LEM_LIBS) -outdir isabelle/vector_instrs lem/vector_instrs/*.lem
	$(LEM) -isa $(LEM_LIBS) -outdir isabelle lem/*.lem
	touch isabelle.stamp

<<<<<<< HEAD
gen_coq coq coq.stamp: $(SAIL_SRCS) src/coq_termination.sail
	$(SAIL) -dprofile \
||||||| 182b439
gen_coq coq coq.stamp: $(SAIL_SRCS) src/coq_termination.sail
	$(SAIL) -dprofile -verbose 1 -memo_z3 \
=======
gen_coq coq coq.stamp: $(SAIL_SRCS) src/termination_measures.sail
	$(SAIL) -dprofile -verbose 1 -memo_z3 \
>>>>>>> master
	        -coq -dcoq_undef_axioms \
	        -coq_output_dir coq -o armv9 -coq_lib arm_extras \
	        -undefined_gen \
	        $(SAIL_SRCS) $(SAIL_FLAGS) \
	        src/termination_measures.sail
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
	$(ISLA_SAIL) $(SAIL_FLAGS) $(SAIL_SRCS) $(SAIL_MAIN) $(ISLA_MAIN) -splice $(ISLA_SPLICE) -o ir/armv9

gen_irx ir/armv9.irx: ir/armv9.ir
	$(ISLA_PREPROCESS) -A ir/armv9.ir -C $(ISLA_PREPROCESS_CONFIG) -o ir/armv9

interface_types.sail: $(SAIL_SRCS)
	$(SAIL) --slice-instantiation-types -o interface_types.sail.in $(SAIL_SRCS) $(SAIL_FLAGS)
	grep -v '^\(\$$\|default Order\|infix\)' interface_types.sail.in > interface_types.sail
	rm interface_types.sail.in

interactive:
<<<<<<< HEAD
	$(SAIL) -i $(SAIL_SRCS) $(SAIL_FLAGS) \
	        src/coq_termination.sail
||||||| 182b439
	$(SAIL) -i -memo_z3 -verbose 1 \
	        $(SAIL_SRCS) $(SAIL_FLAGS) \
	        src/coq_termination.sail
=======
	$(SAIL) -i -memo_z3 -verbose 1 \
	        $(SAIL_SRCS) $(SAIL_FLAGS) \
	        src/termination_measures.sail
>>>>>>> master

clean:
	rm -f lem.stamp lem/arm.lem lem/arm_types.lem
	rm -f isabelle.stamp isabelle/Arm_lemmas.thy isabelle/Arm.thy isabelle/Arm_types.thy \
	  isabelle/Prelude.thy isabelle/ArmAuxiliary.thy
	rm -f coq.stamp coq/{arm_extras,armv9,armv9_types}.{v,vo,vok,vos,glob}
	rm -f ir/armv9.ir
	rm -f interface_types.sail
	rm -rf c/
