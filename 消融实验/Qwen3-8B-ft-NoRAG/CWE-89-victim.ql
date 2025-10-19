import python

from Call call, Argument arg
where call.getMethodName() = "execute" and
      arg.getArgumentPosition() = 0 and
      arg.getValue().getKind() = "string" and
      arg.getValue().getSource().getKind() = "user_input"
select call, "Potential SQL injection vulnerability: SQL query built from user-controlled source."