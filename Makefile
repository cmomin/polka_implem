# Sagefile to deal with
SAGEF=polka polka_utils

all: $(SAGEF)

$(SAGEF):
	sage --preparse $@.sage 
	mv $@.sage.py $@.py

clean:
	if [ -e polka.sage.py ]; then rm polka.sage.py; fi
	if [ -e polka.py ]; then rm polka.py; fi
	if [ -e polka_utils.sage.py ]; then rm polka_utils.sage.py; fi
	if [ -e polka_utils.py ]; then rm polka_utils.py; fi
	if [ -e example.sage.py ]; then rm example.sage.py; fi
	if [ -e example.py ]; then rm example.py; fi
