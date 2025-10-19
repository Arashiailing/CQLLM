/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects unsafe Jinja2 template configurations where autoescaping is disabled,
 *              which can lead to cross-site scripting (XSS) vulnerabilities.
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
 * Identifies unsafe Jinja2 template configurations where autoescaping is disabled.
 * Both Environment and Template constructors accept an 'autoescape' parameter.
 * When autoescaping is disabled (explicitly set to False or omitted),
 * user-provided input may not be properly escaped, creating XSS vulnerabilities.
 * 
 * API References:
 * - Environment: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 */

// Check if invocation uses variable arguments (*args or **kwargs)
predicate hasVariableArguments(API::CallNode call) {
  exists(call.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(call.asCfgNode().(CallNode).getNode().getKwargs())
}

// Check if autoescape is explicitly set to False
predicate isAutoescapeExplicitlyFalse(API::CallNode call) {
  call.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

// Get API nodes for Jinja2's core constructor classes
private API::Node getJinja2CoreConstructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode jinja2ConstructorCall
where
  // Target calls to Jinja2 constructor methods
  jinja2ConstructorCall = getJinja2CoreConstructors().getACall()
  and
  // Exclude calls using variable arguments
  not hasVariableArguments(jinja2ConstructorCall)
  and
  (
    // Case 1: autoescape parameter is omitted
    not exists(jinja2ConstructorCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape is explicitly disabled
    isAutoescapeExplicitlyFalse(jinja2ConstructorCall)
  )
select jinja2ConstructorCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."