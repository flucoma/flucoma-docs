from spellchecker import SpellChecker
from pathlib import Path

spell = SpellChecker()

files = [x for x in Path("doc").rglob("*.rst")]


for page in files:
    with open(page) as text:
        lines = text.readlines();
        for i, line in enumerate(lines):
            word_array = line.split(' ')
            word_array = [x.replace(':', '') for x in word_array]
            word_array = [x for x in word_array if x != '']
            badspell = spell.unknown(word_array)
            for word in badspell:
                print(page.name, word)
