import python

from Call call, StringLiteral str
where call.getTarget() = "print" and
      call.getArg(0) = str and
      str.getValue() contains "request.args.get" and
      str.getValue() contains " + " or
      str.getValue() contains " + " or
      str.getValue() contains "f-string"
select call, "Potential reflected XSS due to direct output of user input."