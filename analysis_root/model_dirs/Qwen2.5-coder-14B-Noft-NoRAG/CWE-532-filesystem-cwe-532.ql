import python
import semmle.python.security.dataflow.SensitiveDataFlow

class CWE532Query extends SensitiveDataFlow::SensitiveDataFlowQuery {
  CWE532Query() {
    this("sensitive information", "log file")
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(FileAccess fa | fa.isWrite() and fa.getFile().hasName("*.log") and sink.asExpr() = fa.getArgument())
  }

  override predicate isSource(DataFlow::Node source) {
    exists(Expr e | e.isCall() and e.getCallee().getName() = "get_sensitive_data" and source.asExpr() = e)
  }
}