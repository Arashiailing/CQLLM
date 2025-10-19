import python
import semmle.python.security.dataflow.FlowSources
import semmle.python.security.dataflow.FlowSinks

class ReflectedXssQuery extends Query {
  ReflectedXssQuery() {
    this.getName() = "Reflected server-side cross-site scripting"
    this.getDescription() = "Writing user input directly to a web page allows for a cross-site scripting vulnerability."
    this.getId() = "py/httphandler-cwe-79"
  }

  private Expr getHttpRequestSource() {
    exists(Expr e, Call call | call.getCallee().getName() = "request" and e = call.getArgument(0) |
      e instanceof FieldAccess and e.getField().getName() = "args" and
      e.getQualifier() instanceof Identifier and e.getQualifier().getName() = "request"
    )
  }

  private Expr getHttpResponseSink() {
    exists(Expr e, Call call | call.getCallee().getName() = "write" and e = call.getArgument(0) |
      e instanceof FieldAccess and e.getField().getName() = "wfile" and
      e.getQualifier() instanceof Identifier and e.getQualifier().getName() = "self"
    )
  }

  from Expr source, Expr sink
  where source = getHttpRequestSource() and sink = getHttpResponseSink()
  select source, "This user input is directly written to the HTTP response, which may lead to a reflected cross-site scripting vulnerability."
}