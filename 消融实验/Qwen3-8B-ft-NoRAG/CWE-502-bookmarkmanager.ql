import python

from pyFunctionCall call
where call.getFunction().getName() = "loads" and call.getFunction().getModule() = "pickle"
select call, "Unsafe deserialization of user-controlled data"