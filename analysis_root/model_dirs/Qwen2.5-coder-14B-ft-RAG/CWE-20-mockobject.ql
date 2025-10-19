/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @tags security
 *       external/cwe/cwe-20
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/mockobject
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Helper predicate to identify unsafe calls to mock methods
predicate unsafe_mock_call(Call call) {
  // Check if the method being called starts with '__'
  call.getFunc().(Attribute::getName/0).(Name::getId/0).matches("__%")
  or
  // Check if the method being called ends with '__'
  call.getFunc().(Attribute::getName/0).(Name::getId/0).matches("%__")
}

// Helper predicate to identify unsafe calls to assert methods
predicate unsafe_assert_call(Call call) {
  // Check if the function being called is assertRaises
  call.getFunc().(Attribute::getName/0).(Name::getId/0) = "assertRaises"
}

// Main query predicate to find problematic test cases
from TestUnit test_case, DataFlow::Node input_node, DataFlow::Node target_node
where
  // Get the last line of the test case
  exists(int last_line | last_line = test_case.getLastLine())
  and
  // Check if there's a test assertion that flows to a dangerous input node
  (
    // Case 1: Unsafe mock calls in test cases
    unsafe_mock_call(input_node.asExpr()) and
    test_case.assertion(target_node.asExpr(), _) and
    DataFlow::flowsto(input_node, target_node)
  )
  or
  // Case 2: Unsafe assert calls in test cases
  (
    unsafe_assert_call(input_node.asExpr()) and
    test_case.assertion(target_node.asExpr(), _) and
    DataFlow::flowsto(input_node, target_node)
  )
select test_case, "Test uses $@ which could be easily bypassed by a test case.", input_node,
  input_node.toString()