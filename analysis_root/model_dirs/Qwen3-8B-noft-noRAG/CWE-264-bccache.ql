import python

from Call call
where call.getMethodName() = "loads" and (
    call.getModule() = "pickle" or
    call.getModule() = "json" or
    call.getModule() = "marshal"
)
select call, "Potential unsafe deserialization detected."