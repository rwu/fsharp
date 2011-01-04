SOURCES := $(patsubst $(srcdir)$(tmpdir)%,$(tmpdir)%,$(patsubst %,$(srcdir)%,$(sources)))

.PHONY: install install-bin install-bin-2 install-bin-4 install-lib

all: do-4-0 do-2-0

install:

clean: clean-4-0 clean-2-0
	@-rm -f $(tmpdir)*

clean-2-0: TARGET := $(TARGET_2_0)
clean-2-0:
	@-rm -rf $(objdir)
	@-rm -f $(outdir)$(ASSEMBLY)
	@-rm -f $(outdir)$(ASSEMBLY).mdb
	@-rm -f $(outdir)$(NAME).xml
	@-rm -f $(outdir)$(NAME).sigdata
	@-rm -f $(outdir)$(NAME).optdata

clean-4-0: TARGET := $(TARGET_4_0)
clean-4-0:
	@-rm -rf $(objdir)
	@-rm -f $(outdir)$(ASSEMBLY)
	@-rm -f $(outdir)$(ASSEMBLY).mdb
	@-rm -f $(outdir)$(NAME).xml
	@-rm -f $(outdir)$(NAME).sigdata
	@-rm -f $(outdir)$(NAME).optdata

do-2-0: DEFINES += $(DEFINES_2_0)
do-2-0: REFERENCES += $(REFERENCES_2_0)
do-2-0: FLAGS += $(FLAGS_2_0)
do-2-0: TARGET := $(TARGET_2_0)
do-2-0: VERSION := $(VERSION_2_0)
do-2-0: monolibdir = $(monolibdir2)
do-2-0: $(objdir) $(objdir)$(TARGET_2_0) $(objdir)$(TARGET_4_0) $(objdir)$(TARGET_2_0)/$(ASSEMBLY)
	@mkdir -p $(outdir)
	@cp $(objdir)$(ASSEMBLY) $(outdir)
	@-cp $(objdir)$(NAME).xml $(outdir)
	@-cp $(objdir)$(ASSEMBLY).mdb $(outdir)
	@if test -e $(objdir)$(NAME).sigdata; then \
		cp $(objdir)$(NAME).sigdata $(outdir); \
	fi
	@if test -e $(objdir)$(NAME).optdata; then \
		cp $(objdir)$(NAME).optdata $(outdir); \
	fi
	@if test "x$(SIGN)" = "x1"; \
		then sn -R $(outdir)$(ASSEMBLY) $(srcdir)../../../mono.snk; \
	fi
	@if test -e Microsoft.FSharp.targets; then \
		cp Microsoft.FSharp.targets $(outdir); \
	fi

do-4-0: DEFINES += $(DEFINES_4_0)
do-4-0: REFERENCES += $(REFERENCES_4_0)
do-4-0: FLAGS += $(FLAGS_4_0)
do-4-0: TARGET := $(TARGET_4_0)
do-4-0: VERSION := $(VERSION_4_0)
do-4-0: monolibdir = $(monolibdir4)
do-4-0: $(objdir) $(objdir)$(TARGET_2_0) $(objdir)$(TARGET_4_0) $(objdir)$(TARGET_4_0)/$(ASSEMBLY)
	@mkdir -p $(outdir)
	@cp $(objdir)$(ASSEMBLY) $(outdir)
	@-cp $(objdir)$(NAME).xml $(outdir)
	@-cp $(objdir)$(ASSEMBLY).mdb $(outdir)
	@if test -e $(objdir)$(NAME).sigdata; then \
		cp $(objdir)$(NAME).sigdata $(outdir); \
	fi
	@if test -e $(objdir)$(NAME).optdata; then \
		cp $(objdir)$(NAME).optdata $(outdir); \
	fi
	@if test "x$(SIGN)" = "x1"; \
		then sn -R $(outdir)$(ASSEMBLY) $(srcdir)../../../mono.snk; \
	fi
	@if test -e Microsoft.FSharp.targets; then \
		cp Microsoft.FSharp.targets $(outdir); \
	fi

install-lib-2: TARGET := $(TARGET_2_0)
install-lib-2: VERSION := $(VERSION_2_0)

install-lib-4: TARGET := $(TARGET_4_0)
install-lib-4: VERSION := $(VERSION_4_0)

install-bin-2: TARGET := $(TARGET_2_0)
install-bin-2: VERSION := 2
install-bin-4: TARGET := $(TARGET_4_0)

install-lib-2 install-lib-4:
	@echo "Installing $(ASSEMBLY)"
	@mkdir -p $(DESTDIR)/$(libdir)
	@mkdir -p $(DESTDIR)/$(libdir)mono/$(TARGET)
	@gacutil -i $(outdir)$(ASSEMBLY) -root $(DESTDIR)/$(libdir) -package $(TARGET)
	@if test -e $(outdir)$(NAME).sigdata; then \
		$(INSTALL_LIB) $(outdir)$(NAME).sigdata $(DESTDIR)/$(libdir)mono/gac/$(NAME)/$(VERSION)__$(TOKEN); \
		ln -fs $(DESTDIR)/$(libdir)mono/gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).sigdata $(DESTDIR)/$(libdir)mono/$(TARGET)/$(NAME).sigdata; \
	fi
	@if test -e $(outdir)$(NAME).optdata; then \
		$(INSTALL_LIB) $(outdir)$(NAME).optdata $(DESTDIR)/$(libdir)mono/gac/$(NAME)/$(VERSION)__$(TOKEN); \
		ln -fs $(DESTDIR)/$(libdir)mono/gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).optdata $(DESTDIR)/$(libdir)mono/$(TARGET)/$(NAME).optdata; \
	fi
	$(INSTALL_LIB) $(outdir)Microsoft.FSharp.targets $(DESTDIR)/$(libdir)mono/$(TARGET)/;

install-bin-2 install-bin-4:
	sed -e 's,[@]DIR[@],$(libdir)mono/$(TARGET),g' -e 's,[@]TOOL[@],fsc.exe,g' < $(topdir)launcher.in > $(outdir)$(NAME)$(VERSION)
	chmod +x $(outdir)$(NAME)$(VERSION)
	@mkdir -p $(DESTDIR)/$(libdir)
	@mkdir -p $(DESTDIR)/$(bindir)
	$(INSTALL_LIB) $(outdir)$(ASSEMBLY) $(DESTDIR)$(libdir)mono/$(TARGET)
	$(INSTALL_BIN) $(outdir)$(NAME)$(VERSION) $(DESTDIR)/$(bindir)

$(objdir) $(objdir)$(TARGET_2_0) $(objdir)$(TARGET_4_0):
	mkdir -p $@

$(objdir)$(TARGET_2_0)/$(ASSEMBLY): $(RESOURCES) $(SOURCES)
	MONO_PATH=$(bootstrapdir) mono $(MONO_OPTIONS) --debug $(FSC) -o:$(objdir)$(ASSEMBLY) $(REFERENCES) $(DEFINES) $(FLAGS) $(patsubst %,--resource:%,$(RESOURCES)) $(SOURCES)

$(objdir)$(TARGET_4_0)/$(ASSEMBLY):  $(RESOURCES) $(SOURCES)
	MONO_PATH=$(bootstrapdir) mono $(MONO_OPTIONS) --debug $(FSC) -o:$(objdir)$(ASSEMBLY) $(REFERENCES) $(DEFINES) $(FLAGS) $(patsubst %,--resource:%,$(RESOURCES)) $(SOURCES)
