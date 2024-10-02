CC = gcc
CFLAGS = -Wall -g
SRCDIR = csrc
LIBDIR = lib
BUILDDIR = build
INCLUDE = -I$(SRCDIR)

SRCS = $(shell find $(SRCDIR) -name '*.c')
OBJS = $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(SRCS))
MULTI_LIB_DIRS = $(shell find $(SRCDIR) -mindepth 1 -type d)
SINGLE_LIBS = $(basename $(notdir $(SRCS)))
MULTI_LIBS = $(notdir $(MULTI_LIB_DIRS))

LIBRARIES = $(addsuffix .a,$(addprefix lib/lib, $(SINGLE_LIBS))) $(addsuffix .a,$(addprefix lib/lib,$(MULTI_LIBS)))

all: $(LIBRARIES)

$(LIBDIR)/lib%.a: $(BUILDDIR)/%.o
	ar rcs $@ $^

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

lib/lib%: $(shell find $(SRCDIR)/$* -name '*.c')
	@mkdir -p $(LIBDIR)
	ar rcs $@ $^

clean:
	rm -rf $(BUILDDIR) $(LIBDIR)/lib*.a

.PHONY: all clean
