import py

from Call call
where call.getKind() = "call" and call.getFunctionName() = "print"
select call, "Potential reflected XSS due to direct output of user input."