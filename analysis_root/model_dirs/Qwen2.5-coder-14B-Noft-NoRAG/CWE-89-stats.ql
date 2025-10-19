import python
import semmle.python.security.dataflow.TaintTracking

/**
 * A class that extends the TaintTracking::Configuration to detect SQL injection vulnerabilities.
 */
class SQLInjectionConfig extends TaintTracking::Configuration {
  SQLInjectionConfig() {
    this = "SQLInjectionConfig"
  }

  override predicate isSource(DataFlow::Node node) {
    exists(CallExpr call, Expr arg |
      call.getCallee().getName() = "input" and
      arg = call.getArgument(0) and
      node.asExpr() = arg
    )
  }

  override predicate isSink(DataFlow::Node node) {
    exists(CallExpr call, Expr arg |
      call.getCallee().getName() = "execute" and
      arg = call.getArgument(0) and
      node.asExpr() = arg
    )
  }
}

/**
 * A query that finds SQL injection vulnerabilities.
 */
from SQLInjectionConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select source, "This user-controlled input is used to build a SQL query, which is vulnerable to SQL injection.", sink