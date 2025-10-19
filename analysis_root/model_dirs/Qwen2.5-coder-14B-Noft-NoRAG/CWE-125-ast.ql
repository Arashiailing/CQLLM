import python

/**
 * Detects CWE-125: Out-of-bounds Read
 * The product reads data past the end, or before the beginning, of the intended buffer.
 */
from Call call, DataFlow::Node source, DataFlow::Node sink
where call.getCallee().getName() = "read" and
      DataFlow::localFlow(source, sink) and
      sink instanceof ArrayAccess and
      sink.getIndex() instanceof BinaryExpr and
      sink.getIndex().getOperator() = "+" and
      sink.getIndex().getLeftOperand() instanceof Identifier and
      sink.getIndex().getRightOperand() instanceof Literal
select call, "This call to'read' may read out-of-bounds due to the addition of a literal offset to the array index."