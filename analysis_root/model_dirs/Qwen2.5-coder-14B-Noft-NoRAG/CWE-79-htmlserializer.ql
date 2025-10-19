import python

from Function f, DataFlow::Node src, DataFlow::Node sink
where f.getName() = "write" or f.getName() = "writelines"
  and DataFlow::localFlow(src, sink)
  and src instanceof Expr
  and sink instanceof Expr
select src, "This input is directly written to the web page, which may lead to a reflected cross-site scripting vulnerability."