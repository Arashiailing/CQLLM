import python

/**
 * This query detects CWE-20: Improper Input Validation.
 * It looks for functions that receive input but do not validate it properly.
 */

from Function func, Parameter param, DataFlow::Node inputNode, DataFlow::Node sinkNode
where
  // Find functions that receive input
  func.hasParameter(param) and
  // Find data flow from input parameter to a sink (e.g., file operation, database query)
  DataFlow::localFlow(func, param, inputNode) and
  DataFlow::localFlow(func, inputNode, sinkNode) and
  // Ensure the input is not validated before reaching the sink
  not exists(DataFlow::Node validationNode |
    DataFlow::localFlow(func, param, validationNode) and
    DataFlow::localFlow(func, validationNode, sinkNode)
  )
select func, param, "Function $func takes input $param which is not validated before being used in a potentially unsafe operation."