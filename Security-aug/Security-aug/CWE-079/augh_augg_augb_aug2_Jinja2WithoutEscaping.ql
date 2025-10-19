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

// Determine if invocation uses variable arguments (*args or **kwargs)
predicate usesVariableArguments(API::CallNode invocation) {
  exists(invocation.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(invocation.asCfgNode().(CallNode).getNode().getKwargs())
}

// Verify if autoescape is explicitly configured as False
predicate autoescapeExplicitlyDisabled(API::CallNode invocation) {
  invocation.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

// Retrieve API nodes for Jinja2's core constructor classes
private API::Node jinja2CoreConstructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode constructorInvocation
where
  // Identify calls to Jinja2 constructor methods
  constructorInvocation = jinja2CoreConstructors().getACall()
  and
  // Exclude invocations using variable arguments
  not usesVariableArguments(constructorInvocation)
  and
  (
    // Scenario 1: autoescape parameter is missing
    not exists(constructorInvocation.getArgByName("autoescape"))
    or
    // Scenario 2: autoescape is explicitly disabled
    autoescapeExplicitlyDisabled(constructorInvocation)
  )
select constructorInvocation, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."