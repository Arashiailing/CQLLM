import python

from Call call, InputSource input
where call.getTarget() = "print" and call.getArgument(0) = input
select call, "Reflected XSS vulnerability due to direct output of user input."