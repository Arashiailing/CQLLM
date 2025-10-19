import python

/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 * not validate or incorrectly validates that the input has the
 * properties that are required to process the data safely and
 * correctly.
 * @id py/SSLCA
 */

class ImproperInputValidation extends DataFlow::Configuration {
  ImproperInputValidation() {
    this = "ImproperInputValidation"
  }

  override predicate isSource(DataFlow::Node src) {
    exists(Call call | call.getCallee().getName() = "input" and call.getArgument(0) = src)
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(Call call | call.getCallee().getName() = "process" and call.getArgument(0) = sink)
  }

  override predicate isSanitizer(DataFlow::Node node) {
    exists(Call call | call.getCallee().getName() = "validate" and call.getArgument(0) = node)
  }
}

from ImproperInputValidation config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select source, "Improper input validation detected.", sink