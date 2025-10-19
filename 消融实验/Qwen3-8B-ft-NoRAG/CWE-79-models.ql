import python
import semmle.code.cpp.dataflow.DataFlow

from PrintStmt p, StringLiteral s, Expr e
where p.getArgs() = [s, e] and
      s.getValue() = "<" and
      e.toString() = "user_input" and
      exists(HttpRequest h, HttpResponse r |
        h.getQueryParameter("user_input") = e and
        r.getBody() = s.getValue() + e.toString())
select p, "Potential reflected XSS vulnerability: user input is directly output in HTML"