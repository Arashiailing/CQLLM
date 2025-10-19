/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects jinja2 template usage where autoescaping is disabled,
 *              which may lead to cross-site scripting vulnerabilities.
 * @kind problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision medium
 * @id py/jinja2/autoescape-false
 * @tags security
 *       external/cwe/cwe-079
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

/*
 * Jinja 2 Documentation References:
 * https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * Note: While documentation doesn't explicitly state it, autoescape parameter
 * is valid during manual Template construction:
 * unsafe_tmpl = Template('Hello {{ name }}!')
 * safe1_tmpl = Template('Hello {{ name }}!', autoescape=True)
 */

// Private helper to identify Jinja2 Environment or Template API nodes
private API::Node jinjaCoreEntity() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode jinjaCall
where
  // Verify call targets Jinja2 Environment/Template
  jinjaCall = jinjaCoreEntity().getACall() and
  // Ensure no variadic arguments (*args) are present
  not exists(jinjaCall.asCfgNode().(CallNode).getNode().getStarargs()) and
  // Ensure no keyword dictionary arguments (**kwargs) are present
  not exists(jinjaCall.asCfgNode().(CallNode).getNode().getKwargs()) and
  // Check autoescape parameter configuration
  (
    // Case 1: autoescape parameter is completely omitted
    not exists(jinjaCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape explicitly set to False
    jinjaCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select jinjaCall, "Jinja2 template usage with autoescape=False may enable XSS attacks."