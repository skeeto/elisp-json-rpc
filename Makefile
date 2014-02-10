EMACS   ?= emacs
BATCH   := $(EMACS) -batch -Q -L .

PACKAGE := json-rpc

EL = json-rpc.el
ELC = $(EL:.el=.elc)

.PHONY : all binary compile package test clean distclean

all : test

compile: $(ELC)

test: compile $(TEST_ELC)
	$(BATCH) -l $(PACKAGE)-tests.el -f ert-run-tests-batch

clean :
	$(RM) *.elc

%.elc : %.el
	$(BATCH) -f batch-byte-compile $<
