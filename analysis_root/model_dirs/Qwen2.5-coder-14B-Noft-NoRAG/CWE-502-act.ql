import python

/**
 * This query detects potential CWE-502: Deserialization of user-controlled data.
 * It looks for deserialization calls where the input is user-controlled.
 */

from Call call, DataFlow::Node source, DataFlow::Node sink
where call.getCallee().getName() = "loads" and
      DataFlow::localFlow(source, sink, call) and
      source instanceof Expr and
      source.asExpr().isUserInput()
select call, "Deserializing user-controlled data may allow attackers to execute arbitrary code."