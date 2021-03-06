# Module.mk for io module
# Copyright (c) 2007 Rene Brun and Fons Rademakers
#
# Author: Rene Brun 06/02/2007

MODNAME      := io
MODDIR       := $(ROOT_SRCDIR)/io/$(MODNAME)
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

IODIR        := $(MODDIR)
IODIRS       := $(IODIR)/src
IODIRI       := $(IODIR)/inc

##### libRIO #####
IOL          := $(MODDIRI)/LinkDef.h
IODS         := $(call stripsrc,$(MODDIRS)/G__RIO.cxx)
IODO         := $(IODS:.cxx=.o)
IODH         := $(IODS:.cxx=.h)

IOH          := $(filter-out $(MODDIRI)/LinkDef%,$(wildcard $(MODDIRI)/*.h))
IOS          := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
IOO          := $(call stripsrc,$(IOS:.cxx=.o))

IODEP        := $(IOO:.o=.d) $(IODO:.o=.d)

IOLIB        := $(LPATH)/libRIO.$(SOEXT)
IOMAP        := $(IOLIB:.$(SOEXT)=.rootmap)

# used in the main Makefile
ALLHDRS      += $(patsubst $(MODDIRI)/%.h,include/%.h,$(IOH))
ALLLIBS      += $(IOLIB)
ALLMAPS      += $(IOMAP)

# include all dependency files
INCLUDEFILES += $(IODEP)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME)

include/%.h:    $(IODIRI)/%.h
		cp $< $@

$(IOLIB):       $(IOO) $(IODO) $(ORDER_) $(MAINLIBS) $(IOLIBDEP)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)" \
		   "$(SOFLAGS)" libRIO.$(SOEXT) $@ "$(IOO) $(IODO)" \
		   "$(IOLIBEXTRA)"

$(call pcmrule,IO)
	$(noop)

$(IODS):        $(IOH) $(IOL) $(ROOTCLINGSTAGE1DEP) $(call pcmdep,IO)
		$(MAKEDIR)
		@echo "Generating dictionary $@..."
		$(ROOTCLINGSTAGE1) -f $@ $(call dictModule,IO) -c $(IOH) $(IOL) && touch lib/libRIO_rdict.pcm


$(IOMAP):       $(IOH) $(IOL) $(ROOTCLINGSTAGE1DEP) $(call pcmdep,IO)
		$(MAKEDIR)
		@echo "Generating rootmap $@..."
		$(ROOTCLINGSTAGE1) -r $(IODS) $(call dictModule,IO) -c $(IOH) $(IOL)
all-$(MODNAME): $(IOLIB)

clean-$(MODNAME):
		@rm -f $(IOO) $(IODO)

clean::         clean-$(MODNAME)

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(IODEP) $(IODS) $(IODH) $(IOLIB) $(IOMAP)

distclean::     distclean-$(MODNAME)

##### extra rules ######
$(IOO): CXXFLAGS += -I$(ROOT_SRCDIR)/core/clib/res
