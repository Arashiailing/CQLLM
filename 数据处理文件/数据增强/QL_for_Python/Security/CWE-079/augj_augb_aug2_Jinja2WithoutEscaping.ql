/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects unsafe Jinja2 template configurations where autoescaping is disabled,
 *              creating potential cross-site scripting (XSS) vulnerabilities.
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
 * This query identifies unsafe Jinja2 template configurations where:
 * 1. The 'autoescape' parameter is explicitly disabled (set to False)
 * 2. The 'autoescape' parameter is omitted (defaulting to unsafe behavior)
 * 
 * Vulnerability occurs when user-provided input isn't properly escaped,
 * allowing XSS attacks. Affects both Environment and Template constructors.
 * 
 * API References:
 * - Environment: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 */

// Checks if call uses variable arguments (*args or **kwargs)
predicate usesVariableArguments(API::CallNode callNode) {
  exists(callNode.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(callNode.asCfgNode().(CallNode).getNode().getKwargs())
}

// Detects explicit autoescape=False configuration
predicate hasAutoescapeDisabled(API::CallNode callNode) {
  callNode.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

// Retrieves Jinja2's core constructor API nodes
private API::Node jinja2CoreConstructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode jinja2ConstructorCall
where
  // Target Jinja2 constructor calls
  jinja2ConstructorCall = jinja2CoreConstructors().getACall()
  and
  // Exclude calls using variable arguments
  not usesVariableArguments(jinja2ConstructorCall)
  and
  (
    // Case 1: autoescape parameter is missing (defaults to unsafe)
    not exists(jinja2ConstructorCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape explicitly disabled
    hasAutoescapeDisabled(jinja2ConstructorCall)
  )
select jinja2ConstructorCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."