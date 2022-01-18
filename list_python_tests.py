
import unittest
import re 
from pathlib import Path

def list_tests_from(path):
    for t in Path(path).glob('test*.py'):
        tmodule = f'flucoma.doc.test.{t.stem}'
        for suite in unittest.TestLoader().loadTestsFromName(tmodule):
            for test in suite:
                parts = re.split("(.+)\((.+)\)",str(test))
                print(f'{parts[2]}.{parts[1]}')
                    
list_tests_from('flucoma/doc/test')                    
