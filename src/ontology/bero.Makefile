## Customize Makefile settings for bero
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

$(ONT)-full.owl: $(SRC) $(OTHER_SRC) $(IMPORT_FILES)
	$(ROBOT) merge --input $< $(patsubst %, -i %, $(OTHER_SRC)) $(patsubst %, -i %, $(IMPORT_FILES)) \
		reason --reasoner ELK --equivalent-classes-allowed asserted-only --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		$(SHARED_ROBOT_COMMANDS) annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@

$(IMPORTDIR)/ncit_import.owl: $(MIRRORDIR)/ncit.owl $(IMPORTDIR)/ncit_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $< \
        filter --term NCIT:XXXXX --select "self descendants" \ 
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi
