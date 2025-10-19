import py

from Call call
where call.getMethod().getName() = "list.__getitem__"
let index = call.getArg(0)
let list = call.getReceiver()
where (index < 0) or (index >= list.length)
select call, "Potential out-of-bounds read"