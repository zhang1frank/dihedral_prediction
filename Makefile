keep=Makefile:*.gitignore:*.md
keepdir=data:models:notebooks:src:*.git

all: pull_research_data

pull_research_data: pull_anglor pull_spinex pull_spider pull_ccpdb30

./data/raw:
	mkdir -p ./data/raw

pull_anglor: ./data/raw
	[ -f ./data/raw/anglor_460_validation.json ] || cat ./data/external/anglor_460_validation.txt | python ./src/pull_pdb.py ./data/raw/anglor_460_validation.json ./data/raw/anglor_460_validation_log.txt
	[ -f ./data/raw/anglor_500_training.json ] || cat ./data/external/anglor_500_training.txt | python ./src/pull_pdb.py ./data/raw/anglor_500_training.json ./data/raw/anglor_500_training_log.txt
	[ -f ./data/raw/anglor_1029_testing.json ] || cat ./data/external/anglor_1029_testing.txt | python ./src/pull_pdb.py ./data/raw/anglor_1029_testing.json ./data/raw/anglor_1029_testing_log.txt
	(GLOBIGNORE=$(keep)":"$(keepdir); rm -rf *)

pull_spinex: ./data/raw
	[ -f ./data/raw/list1833.json ] || cat ./data/external/list.1833 | python ./src/pull_pdb.py ./data/raw/list1833.json ./data/raw/list1833_log.txt
	[ -f ./data/raw/list1975.json ] || cat ./data/external/list.1975 | python ./src/pull_pdb.py ./data/raw/list1975.json ./data/raw/list1975_log.txt
	[ -f ./data/raw/list2479.json ] || cat ./data/external/list.2479 | python ./src/pull_pdb.py ./data/raw/list2479.json ./data/raw/list2479_log.txt
	[ -f ./data/raw/list2640.json ] || cat ./data/external/list.2640 | python ./src/pull_pdb.py ./data/raw/list2640.json ./data/raw/list2640_log.txt
	(GLOBIGNORE=$(keep)":"$(keepdir); rm -rf *)

pull_spider: ./data/raw
	[ -f ./data/raw/ts1199.json ] || cat ./data/external/ts1199.txt | grep \> | cut -c 2- | python ./src/pull_pdb.py ./data/raw/ts1199.json ./data/raw/ts1199_log.txt
	[ -f ./data/raw/tr4590.json ] || cat ./data/external/tr4590.txt | grep \> | cut -c 2- | python ./src/pull_pdb.py ./data/raw/tr4590.json ./data/raw/tr4590_log.txt
	(GLOBIGNORE=$(keep)":"$(keepdir); rm -rf *)

pull_ccpdb30: ./data/raw
	[ -f ./data/raw/ccpdb30.json ] || cat ./data/external/ccpdb30.txt | grep \> | cut -c 2- | cut -d . -f 1 | python ./src/pull_pdb.py ./data/raw/ccpdb30.json ./data/raw/ccpdb30_log.txt
	(GLOBIGNORE=$(keep)":"$(keepdir); rm -rf *)

.PHONY: clean
clean:
	rm -rf ./data/raw
