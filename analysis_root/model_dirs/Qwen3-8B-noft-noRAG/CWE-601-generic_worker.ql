import python
import semmle.code.cpp.commons.LibraryFunction

from Module m, Function f, Call c, Parameter p, Variable v
where 
  m.getName() = "requests" and
  f.getName() = "get" and
  c.getTarget() = f and
  p.getIndex() = 0 and
  v.getValue() = c.getArg(0) and
  v.getType().getName() = "str"
select v, "Potential URL redirection using unvalidated user input"

import python

from Call c, Argument a, Variable v
where 
  c.getMethodName() = "redirect" and
  a.getPosition() = 0 and
  v = a.getExpression() and
  exists (Variable param, Assign assign |
    assign.getLeft() = param and
    assign.getRight() = v and
    param.getType().isString() and
    param.getSource().isFromRequest())
select v, "Potential URL redirection with unvalidated parameter"