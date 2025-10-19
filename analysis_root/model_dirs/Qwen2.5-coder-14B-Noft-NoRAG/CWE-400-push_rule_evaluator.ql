import python

/**
 * CWE-400: Uncontrolled Resource Consumption
 * This query detects instances where the product does not properly control the allocation and maintenance of a limited resource.
 */

class UncontrolledResourceConsumption extends DataFlow::Query {
  UncontrolledResourceConsumption() {
    this.getFlows() = from Call call, DataFlow::Node source, DataFlow::Node sink
                      where call.getCallee().getName() = "open" or call.getCallee().getName() = "read"
                      and source.asExpr() instanceof LocalVarDecl
                      and sink.asExpr() instanceof LocalVarDecl
                      select source, sink
  }
}