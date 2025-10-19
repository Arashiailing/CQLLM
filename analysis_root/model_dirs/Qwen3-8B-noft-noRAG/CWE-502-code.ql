import python

from Call call, Argument arg
where 
  call.getCallee().getName() in ["pickle.loads", "marshal.loads"] and
  arg.getArgumentIndex() = 0 and
  exists(Source source | source.getLocation() = arg.getValue().getLocation() and
    (source.getType() = "UserInput" or
     source.getType() = "HTTPRequestParameter" or
     source.getType() = "CommandlineArgument"))
select call, "Potential unsafe deserialization of user-controlled data"