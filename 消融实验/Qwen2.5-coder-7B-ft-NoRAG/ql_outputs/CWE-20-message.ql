/**
 * @name CWE-20: Improper Input Validation
 * @id py/message
 */
import python
import semmle.python.security.dataflow.InsecureInputValidationQuery

predicate improper_input_validation(Node node) {
  exists(InsecureInputValidationFlow::PathNode source, InsecureInputValidationFlow::PathNode sink |
    InsecureInputValidationFlow::flowPath(source, sink) and
    source.getNode() = node
  )
}

from Node node
where improper_input_validation(node)
select node, "Improper input validation detected."