import py

from Call call
where call.getFunction().getName() = "loads" and call.getFunction().getModule() = "pickle"
and call.getArgument(0) is UserInput
select call, "Unsafe deserialization of user-controlled data"