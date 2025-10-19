import python

from Call call, StringConcatenation sc
where call.getTarget().getName() = "print"
  and call.getArgument(0) = sc
select call, "Reflected XSS vulnerability"