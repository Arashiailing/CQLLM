import python

from Call call
where call.getTarget().getName() = "loads" and call.getTarget().getModule() = "pickle"
  and exists (Source source where source in call.getArgument(0).getValue().getSources() and source.getKind() = "userInput")
select call, "Potential unsafe deserialization due to user input."