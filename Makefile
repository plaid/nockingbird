COFFEE = node_modules/.bin/coffee
MOCHA = node_modules/.bin/mocha --compilers coffee:coffee-script/register
XYZ = node_modules/.bin/xyz --message X.Y.Z --tag X.Y.Z --script scripts/prepublish

JS_FILES = $(patsubst src/%.coffee,lib/%.js,$(shell find src -type f))


.PHONY: all
all: $(JS_FILES)

lib/%.js: src/%.coffee
	$(COFFEE) --compile --output $(@D) -- $<


.PHONY: clean
clean:
	rm -f -- $(JS_FILES)


.PHONY: release-patch release-minor release-major
release-patch: LEVEL = patch
release-minor: LEVEL = minor
release-major: LEVEL = major

release-patch release-minor release-major:
	@$(XYZ) --increment $(LEVEL)


.PHONY: setup
setup:
	npm install


.PHONY: test
test: all
	$(MOCHA)
