all: pull_research_data

pull_research_data: pull_anglor pull_spinex
# to be added: pull_ccpdb30 pull_spider pull_spinex

./data/raw:
				mkdir -p ./data/raw

pull_anglor: ./data/raw
				cat ./data/external/anglor_460_validation.txt | python ./src/pull_pdb.py ./data/raw/anglor_460_validation.json ./data/raw/anglor_460_validation_log.txt
				cat ./data/external/anglor_500_training.txt | python ./src/pull_pdb.py ./data/raw/anglor_500_training.json ./data/raw/anglor_500_training_log.txt
				cat ./data/external/anglor_1029_testing.txt | python ./src/pull_pdb.py ./data/raw/anglor_1029_testing.json ./data/raw/anglor_1029_testing_log.txt

pull_spinex: ./data/raw
				cat ./data/external/list.1833 | python ./src/pull_pdb.py ./data/raw/list1833.json ./data/raw/list1833_log.txt
				cat ./data/external/list.1975 | python ./src/pull_pdb.py ./data/raw/list1975.json ./data/raw/list1975_log.txt
				cat ./data/external/list.2479 | python ./src/pull_pdb.py ./data/raw/list2479.json ./data/raw/list2479_log.txt
				cat ./data/external/list.2640 | python ./src/pull_pdb.py ./data/raw/list2640.json ./data/raw/list2640_log.txt


.PHONY: clean
clean:
				rm -rf ./data/raw
