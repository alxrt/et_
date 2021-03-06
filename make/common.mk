REL_COMMAND := start stop console remote_console attach ping

all: app

app: $(REBAR) deps
	@$(REBAR) compile

deps: $(REBAR) 
	@$(REBAR) get-deps

clean: $(REBAR)
	(find ./apps -name "*.beam"|xargs rm -v)||true
	@$(REBAR) clean

depclean:
	rm -rvf ./deps

dc: clean relclean

ddclean: depclean dc

test: $(REBAR) app
	@$(REBAR) eunit skip_deps=true $(if $(SUITES),suites=$(SUITES),)

ct: $(REBAR) app
	@$(REBAR) ct skip_deps=true

BASIC_PLT := basic.plt
DIALYZER := dialyzer
DIALYZER_APPS := kernel stdlib sasl inets crypto public_key ssl

$(BASIC_PLT): build-plt

build-plt: 
	@$(DIALYZER) --build_plt --output_plt $(BASIC_PLT) --apps $(DIALYZER_APPS)

dialyze: $(BASIC_PLT)
	$(DIALYZER) -r apps/*/src $(DEPS)/*/src \
	-I apps/*/include -I $(DEPS)/*/include \
	 --no_native --src --plt $(BASIC_PLT) -Werror_handling \
		-Wrace_conditions -Wunmatched_returns -Wunderspecs || true

xref: $(REBAR) app
	@$(REBAR) xref skip_deps=true

doc: $(REBAR) app
	@$(REBAR) doc skip_deps=true

lock-deps: $(REBAR) deps
	@$(REBAR) lock-deps skip_deps=true ignore=meck,moka,proper,rebar skip_dirs=rel

.PHONY: app doc deps clean test ct xref lock-deps build-plt
