#Customize Makefile settings for bero
#
#If you need to customize your Makefile, make
#changes here rather than in the main Makefile

$(ONT)-full.owl: $(SRC) $(OTHER_SRC) $(IMPORT_FILES)
	$(ROBOT) merge --input $< $(patsubst %, -i %, $(OTHER_SRC)) $(patsubst %, -i %, $(IMPORT_FILES)) \
		reason --reasoner ELK --equivalent-classes-allowed asserted-only --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		$(SHARED_ROBOT_COMMANDS) annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@


$(IMPORTDIR)/ncit_import.owl: $(MIRRORDIR)/ncit.owl $(IMPORTDIR)/ncit_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) remove -i $< \
        --term oboInOwl:hasExactSynonym \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi


$(IMPORTDIR)/edam_import.owl: $(MIRRORDIR)/edam.owl $(IMPORTDIR)/edam_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) extract -i $< \
		--method MIREOT \
		--branch-from-term http://edamontology.org/topic_0003 \
		remove \
        --select annotation-properties \
		--exclude-term rdfs:label \
		--exclude-term IAO:0000115 \
		--exclude-term oboInOwl:hasSubset \
		--exclude-term oboInOwl:hasBroadSynonym \
		--exclude-term oboInOwl:hasRelatedSynonym \
		--exclude-term oboInOwl:hasNarrowSynonym \
		--exclude-term oboInOwl:hasNarrowSynonym \
		--exclude-term oboInOwl:hasExactSynonym \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/pato_import.owl: $(MIRRORDIR)/pato.owl $(IMPORTDIR)/pato_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) extract -i $< \
		--method MIREOT \
		--branch-from-term PATO:0001018 \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi