/**
 * @name Uncontrolled command line
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/apkleaks-cwe-78
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

import python
import semmle.python.ApiGraphs
import FluentApiModel
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

predicate non_user_provided_source(ControlFlowNode node) {
  exists(Function f |
    f.isStdLib() and
    node = f.getReturn()
  )
}

ControlFlowNode user_provided_node(ControlFlowNode start, ControlFlowNode end) {
  (
    start instanceof Source and
    not non_user_provided_source(start)
  ) or
  exists(DataFlow::TypeTracker tracker | 
    user_provided_node(tracker.getStart(), start) and
    end = tracker.getEnd()
  )
}

predicate temporary_name_call(Call call) { 
  exists(Function func | 
    call.getScope() = func.getScope() and
    func.getName() = "os" and
    call = func.getMember("tmpnam").getACall()
  )
}

predicate temporary_name_flow(ControlFlowNode src, ControlFlowNode dst) {
  dst = src.getAnInFlowTo() and
  not src = dst and
  temporary_name_flow(src.getAnInFlowTo(), dst)
}

predicate temporary_name_use(ControlFlowNode use, string funcName) {
  exists(API::builtin("os.tmpnam").getMember(funcName).getACall().asCfgNode().(Call).getNode()) and
  exists(API::builtin("os.tmpnam").getMember(funcName).getACall().asCfgNode().(Call).getNode().(Sink)) and
  use = API::builtin("os.tmpnam").getMember(funcName).getACall().asCfgNode().(Call).getNode()
}

predicate temp_file_creation(Sink creation, string funcName) {
  exists(Function func | 
    func.isStdLib() and
    creation.(Source).getFile() = func.getScope() and
    (
      (func.getName() = "tempfile" and 
        func.getScope().getRelativeFilename() = "%/tempfile.py")
      or
      (func.getName() = "tempfile" and 
        func.getScope().getRelativeFilename() = "%/pyi/lib-python/%/tempfile.py")
    )
  ) and
  (
    creation.asExpr() = API::builtin("tempfile").getMember("NamedTemporaryFile").getACall().asExpr()
    or
    creation.asExpr() = API::builtin("tempfile").getMember("mkstemp").getACall().asExpr()
    or
    creation.asExpr() = API::builtin("tempfile").getMember("mkdtemp").getACall().asExpr()
  ) and
  funcName = "tmpnam"
}

ControlFlowNode tainted_src(ControlFlowNode start, ControlFlowNode end) {
  user_provided_node(start, end) or
  temporary_name_flow(start, end)
}

Sink taint_sink(ControlFlowNode src) {
  sink = src.asExpr().(Sink) and
  tainted_src(_, src) and
  not temporary_name_use(src, _)
}

Sink taint_sink(ControlFlowNode src, string funcName) {
  temp_file_creation(sink, funcName) and
  temporary_name_flow(src, sink.asExpr())
}

from DataFlow::CallCfgNode cmd_execution, DataFlow::TypeTracker tracker, Sink src, string funcName
where
  (
    tracker.getStart() = cmd_execution and
    tracker.getEndingValue() = src and
    (
      taint_sink(tracker.getEnd(), funcName)
      or
      taint_sink(tracker.getEnd())
    )
  )
select cmd_execution.asExpr(), "Command line depends on a $@.", src.asExpr(), "user-provided value"