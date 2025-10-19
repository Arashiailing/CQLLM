/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @description nan
 * @kind problem
 * @tags security
 *       external/cwe/cwe-264
 * @problem.severity recommendation
 */

import python
import semmle.python.ApiGraphs

// Helper function to determine if a node is a security group attribute
predicate is_security_group_attribute(API::Node attr_node) {
  attr_node = API::moduleImport("grp").getMember("getgrnam").getReturn()
  or
  attr_node = API::moduleImport("grp").getMember("getgrgid").getReturn()
}

// Helper function to find nodes where untrusted user input flows into security group attributes
DataFlow::Node untrusted_input_to_attr_flow(DataFlow::Node flow_source, API::Node target_attr) {
  is_security_group_attribute(target_attr) and
  (
    flow_source = target_attr.getAValueReachableFromSource() and
    not exists(StringLiteral string_value |
      flow_source.asExpr() = string_value and
      string_value.getText() in [
        ".",
        "..",
        "/.",
        "/.."
      ]
    )
  )
  or
  (
    untrusted_input_to_attr_flow(flow_source.(DataFlow::Config), any(API::Node non_config_node)) and
    not exists(non_config_node)
  )
}

// Main query to identify unsafe usage patterns in security group handling
from Call vulnerable_call, DataFlow::Node input_source, API::Node target_attr
where
  untrusted_input_to_attr_flow(input_source, target_attr) and
  vulnerable_call = target_attr.getACall()
select vulnerable_call, "Untrusted user input flows to " + target_attr.toString()