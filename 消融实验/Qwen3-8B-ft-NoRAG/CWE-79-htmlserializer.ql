import semmle.code.py.Python

from StringInterpolation s, Variable v
where s.getInterpolatedVariables().has(v) and v.isUserInput()
select s, "Potential reflected XSS due to unescaped user input."

from StringConcatenation s, Variable v
where s.getConcatenatedVariables().has(v) and v.isUserInput()
select s, "Potential reflected XSS due to unescaped user input."