import python

from Call call
where 
  (call.getCallee().getName() = "run" and call.getModule() = python.subprocess) 
  and call.getArgument(1).getValue() is true 
  and exists(arg in call.getArguments() where arg.getType().isString())
  or 
  (call.getCallee().getName() = "call" and call.getModule() = python.subprocess) 
  and call.getArgument(1).getValue() is true 
  and exists(arg in call.getArguments() where arg.getType().isString())
  or 
  (call.getCallee().getName() = "system" and call.getModule() = python.os) 
  and exists(arg in call.getArguments() where arg.getType().isString())