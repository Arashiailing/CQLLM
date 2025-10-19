import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.strings.StringHandling

from Method m, StringLiteral s, Variable v
where 
  m.hasName("print") and
  s.getValue().endsWith("%s") and
  exists(Argument arg |
    arg.getFunction() = m and
    arg.isPositional() and
    v = arg.getVariable() and
    v.getType().isString()
  )
select m, "Potential reflected XSS vulnerability: user input is directly formatted into HTML output."