import py

from Call call, Argument arg
where call.getCallee() = "pickle.loads"
  and arg.getArgumentIndex() = 0
  and exists (py.dataFlow().getSource(arg.getExpression(), "user-controlled"))
select call, "Unsafe deserialization of user-controlled data."