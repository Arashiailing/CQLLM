import semmle.python.security.dataflow.FlowSources
import semmle.python.security.dataflow.FlowSinks
import semmle.python.security.dataflow.FlowSanitizers

class CommandInjection extends DataFlow::Query {
  CommandInjection() {
    this.hasFlowPath()
  }

  override predicate isSource(DataFlow::Node src) {
    src instanceof FlowSources::CommandInjectionSource
  }

  override predicate isSink(DataFlow::Node sink) {
    sink instanceof FlowSinks::CommandInjectionSink
  }

  override predicate isSanitizer(DataFlow::Node sanitizer) {
    sanitizer instanceof FlowSanitizers::CommandInjectionSanitizer
  }
}