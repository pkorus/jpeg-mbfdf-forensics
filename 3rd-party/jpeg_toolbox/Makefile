CXX = mex

CXXFLAGS= #-O3 -funroll-loops -march=native -mfpmath=sse -ftree-vectorize
CPPFLAGS=

SRC_DIR=./

ARCH=$(shell uname -m)

ifeq ($(ARCH),x86_64)
        EXT=mexa64
else
        EXT=mexglx
endif

FILES=jpeg_read jpeg_write


ifdef JPEGV8
LIBJPEG_MAIN_DIR=../../libs
LIBJPEG_DIR=$(LIBJPEG_MAIN_DIR)/jpeg-8d
LIBJPEG_LIB_A=$(LIBJPEG_DIR)/.libs/libjpeg.a
LIBJPEG_ARCH_NAME=jpegsrc.v8d.tar.gz
else
LIBJPEG_MAIN_DIR=../../libs
LIBJPEG_DIR=$(LIBJPEG_MAIN_DIR)/jpeg-6b
LIBJPEG_LIB_A=$(LIBJPEG_DIR)/libjpeg.a
LIBJPEG_ARCH_NAME=jpegsrc-v6b.tar.gz
endif
LIBJPEG_ARCH=$(LIBJPEG_DIR)/../$(LIBJPEG_ARCH_NAME)
LIBJPEG_CONF=./configure
LIBJPEG_CONF_EXE=$(LIBJPEG_CONF) CPPFLAGS=-fPIC
LIBJPEG_MAKE=$(LIBJPEG_DIR)/Makefile

TFILES=$(FILES:%=%.$(EXT))

INC=-I$(LIBJPEG_DIR)

LIBS=$(LIBJPEG_LIB_A)

DO_C_O_RULE=$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPTFLAG) $(INC) $(LIBS) -o $@ $<

all : $(TFILES)

$(SRC_DIR)/%.$(EXT) : $(SRC_DIR)/%.c $(LIBJPEG_LIB_A)
	$(DO_C_O_RULE)

$(LIBJPEG_LIB_A) : $(LIBJPEG_MAKE)
	cd $(LIBJPEG_DIR); make;

$(LIBJPEG_MAKE) : $(LIBJPEG_CONF)
	cd $(LIBJPEG_DIR); $(LIBJPEG_CONF_EXE);	

$(LIBJPEG_CONF) : #$(LIBJPEG_ARCH)
	cd $(LIBJPEG_MAIN_DIR); tar xf $(LIBJPEG_ARCH_NAME)

clean : 
	@for i in $(TFILES) ; do \
		rm -f $$i ; \
		echo rm -f $$i ; \
	done
	rm -rf $(LIBJPEG_DIR)
	#cd $(LIBJPEG_DIR); make clean;
