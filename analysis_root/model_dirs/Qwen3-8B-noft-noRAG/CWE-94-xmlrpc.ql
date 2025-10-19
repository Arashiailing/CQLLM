import python

from Call call
where call.getFunction().getName() in ("eval", "exec", "compile", "__import__")
select call, "Potential code injection vulnerability through dangerous function usage"