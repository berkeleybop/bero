#Customize Makefile settings for bero
#
#If you need to customize your Makefile, make
#changes here rather than in the main Makefile

MESH_TERMS_FILE = imports/mesh_terms.txt
NCIT_TERMS_FILE = imports/ncit_terms.txt
MAIN_FILES_RELEASE = $(foreach n,$(MAIN_FILES), ../../$(n))

$(ONT)-full.owl: $(SRC) $(OTHER_SRC) $(IMPORT_FILES)
	$(ROBOT) merge --input $< $(patsubst %, -i %, $(OTHER_SRC)) $(patsubst %, -i %, $(IMPORT_FILES)) \
		reason --reasoner ELK --equivalent-classes-allowed all --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		$(SHARED_ROBOT_COMMANDS) annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@


$(IMPORTDIR)/chebi_import.owl: $(MIRRORDIR)/chebi.owl $(IMPORTDIR)/chebi_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) merge -i $< \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi


$(IMPORTDIR)/ncit_import.owl: $(MIRRORDIR)/ncit.owl $(IMPORTDIR)/ncit_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) extract -i $< \
		--method MIREOT \
		--branch-from-terms $(NCIT_TERMS_FILE)  \
		remove \
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

$(IMPORTDIR)/mesh_import.owl: $(MIRRORDIR)/mesh.owl
	if [ $(IMP) = true ]; then $(ROBOT) extract -i $< \
		--method MIREOT \
		--branch-from-terms $(MESH_TERMS_FILE)  \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/obi_import.owl: $(MIRRORDIR)/obi.owl $(IMPORTDIR)/obi_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) remove -i $< \
		--term OBI:0000011 \
		--select "self descendants" \
		--signature true \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/ncbitaxon_import.owl: $(MIRRORDIR)/ncbitaxon.owl $(IMPORTDIR)/ncbitaxon_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) merge -i $(MIRRORDIR)/ncbitaxon.owl  \
	remove --term "oboInOwl:hasOBONamespace" \
		--term "oboInOwl:hasDbXref" \
		--term "http://www.geneontology.org/formats/oboInOwl#hasAlternativeId" \
		--term "http://purl.obolibrary.org/obo/ncbitaxon#has_rank" \
    $(ANNOTATE_CONVERT_FILE); fi

deploy_release:
	@test $(GHVERSION)
	ls -alt $(MAIN_FILES_RELEASE)
	gh release create $(GHVERSION) --notes "TBD." --title "$(GHVERSION)" --draft $(MAIN_FILES_RELEASE)  --generate-notes

###########################
### Debugging section #####
### Ad hoc commands #######
###########################

$(TMPDIR)/bero-merged.owl: $(SRC) $(OTHER_SRC) $(IMPORT_FILES)
	$(ROBOT) merge --input $< $(patsubst %, -i %, $(OTHER_SRC)) $(patsubst %, -i %, $(IMPORT_FILES)) -o $@

$(TMPDIR)/bero-merged.ofn: $(TMPDIR)/bero-merged.owl
	$(ROBOT) convert --input $< -o $@

$(TMPDIR)/explain_ncit.md: $(TMPDIR)/bero-merged.owl
	$(ROBOT) explain -i $< --axiom "'Omacetaxine' EquivalentTo 'Omacetaxine Mepesuccinate'" --explanation $@

$(TMPDIR)/explain_envo1.md: $(TMPDIR)/bero-merged.owl
	$(ROBOT) explain -i $< --axiom "'fluid astronomical body part' EquivalentTo 'compound astronomical body part'" --explanation $@

$(TMPDIR)/explain_envo2.md: $(TMPDIR)/bero-merged.owl
	$(ROBOT) explain -i $< --axiom "'surface of an astronomical body' EquivalentTo 'surface layer'" --explanation $@

$(TMPDIR)/explain_obi1.md: $(TMPDIR)/bero-merged.owl
	$(ROBOT) explain -i $< --axiom "'calcium cation assay' EquivalentTo 'ionized calcium assay'" --explanation $@

$(TMPDIR)/explain_obi2.md: $(TMPDIR)/bero-merged.owl
	$(ROBOT) explain -i $< --axiom "'lower respiratory tract specimen' EquivalentTo 'lower respiratory tract aspirate specimen'" --explanation $@

reason_bero: $(TMPDIR)/bero-merged.owl
	$(ROBOT) reason -i $< --reasoner ELK --equivalent-classes-allowed asserted-only

debug_equivs: $(TMPDIR)/explain_ncit.md $(TMPDIR)/explain_envo1.md $(TMPDIR)/explain_envo2.md $(TMPDIR)/explain_obi1.md $(TMPDIR)/explain_obi2.md
	cat $^

debug_print_labels: $(TMPDIR)/bero-merged.ofn
	grep label.*NCIT_C179199 $<
	grep "label.*NCIT_C1127 " $<
	grep label.*ENVO_01001479 $<
	grep label.*ENVO_01001784 $<
	grep label.*OBI_2100024 $<
	grep label.*OBI_0003012 $<
	grep label.*ENVO_01001483 $<
	grep label.*ENVO_00010504 $<
	grep label.*OBI_0002781 $<
	grep label.*OBI_0002783 $<
