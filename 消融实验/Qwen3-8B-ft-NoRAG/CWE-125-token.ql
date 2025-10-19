import py

from StringSlice slice
where slice.start > slice.str.len() or slice.end > slice.str.len()
select slice, "Potential out-of-bounds read in string slice"

from Call call
where call.getMethod().getName() = "getitem" and call.getArg(0).getType().isString()
and call.getArg(1).getType().isInt()
select call, "Potential out-of-bounds read in string index access"