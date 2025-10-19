import py
import strings

from Call call, StringLiteral string
where call.getMethod().getName() = "execute"
  and call.getArg(0) = string
  and string.containsUserInput()
select call