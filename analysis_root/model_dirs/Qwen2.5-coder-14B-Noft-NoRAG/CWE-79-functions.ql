import python

/**
 * Reflected server-side cross-site scripting (XSS) vulnerability query.
 */
from Function f, DataFlow::Node source, DataFlow::Node sink
where f.getName() = "some_function" and
      DataFlow::localFlow(source, sink) and
      source instanceof Expr and
      sink instanceof Expr and
      source.asExpr().getValue() instanceof StringLiteral and
      sink.asExpr().getValue() instanceof StringLiteral
select sink, "This function writes user input directly to a web page, which can lead to a reflected XSS vulnerability."