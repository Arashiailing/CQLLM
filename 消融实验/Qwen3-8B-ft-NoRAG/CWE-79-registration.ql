import python

from Call call, Parameter p, StringLiteral sl
where call.getMethod().getName() = "print" and
      p = call.getParameters()[0] and
      p.getType().getName() = "str" and
      sl.getStringLiteral().contains(p.getValue()) and
      sl.getStringLiteral().contains("<") and
      sl.getStringLiteral().contains(">")
select call, "Potential reflected XSS vulnerability due to direct user input in HTML output."