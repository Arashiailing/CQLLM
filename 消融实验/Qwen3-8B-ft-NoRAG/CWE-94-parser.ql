import python
import semmle.code.cpp.Expressions
import semmle.code.cpp.ControlFlow

from Call site, StringLiteral, Input
where
  site = Call site("eval")
  or site = Call site("exec")
  or site = Call site("subprocess.Popen")
  or site = Call site("subprocess.call")
  or site = Call site("subprocess.run")
  or site = Call site("input")
  or site = Call site("raw_input")
  and site.getArgument(0) = StringLiteral()
  and site.getArgument(0).getValue() = Input()
select site, "Potential code injection vulnerability via unsanitized user input"