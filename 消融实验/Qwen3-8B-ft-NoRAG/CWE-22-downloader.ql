import python

from Call call, Parameter param
where call.getCallee().getName() = "join" and call.getCallee().getModule() = "os.path"
  and call.getParameters().has(param)
  and param.getSource().isUserInput()
select call, "Potential path injection via os.path.join with user-controlled parameter"