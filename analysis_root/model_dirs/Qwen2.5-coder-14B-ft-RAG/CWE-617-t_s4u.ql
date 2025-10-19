/**
 * @name CWE-617: Reachable Assertion
 * @description nan
 * @kind problem
 * @id py/t_s4u
 */

import python

predicate test_sink(ControlFlowNode target, ControlFlowNode orig, string message) {
  target = orig and
  message = "This assertion will be reached."
}

predicate test_source(ControlFlowNode target, string message) {
  exists(Call c |
    c.getScope().getScope*() = Module m and
    m.isTestModule() and
    (
      c.getFunc().(Name).getId() = "assertEqual" or
      c.getFunc().(Name).getId() = "assertTrue"
    )
    |
    target = c and
    message = "Test method."
  )
}

from ControlFlowNode target, ControlFlowNode orig, string message
where test_sink(target, orig, message) and test_source(orig, message)
select target, message