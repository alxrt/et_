rel: relclean app rel/$(APP)

rel/$(APP):
	@$(REBAR) generate $(OVERLAY_VARS)

relclean:
	@rm -rf rel/$(APP)

pull: dc relclean
	hg pull&&hg update --clean

co:
	hg commit -m Autocommit||true

push: co
	hg push