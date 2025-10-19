/**
 * @name Jinja2 templating with autoescape=False
 * @description Using jinja2 templates with 'autoescape=False' can
 *              cause a cross-site scripting vulnerability.
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
 * This query identifies potentially unsafe Jinja2 template configurations.
 * Both Environment and Template constructors accept an 'autoescape' parameter.
 * When autoescape is disabled (explicitly set to False or left unspecified),
 * the application becomes vulnerable to cross-site scripting (XSS) attacks
 * as user-provided input won't be properly escaped.
 * 
 * API References:
 * - Environment: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 */

// Define predicate to check for calls with variable arguments
predicate usesVariableArguments(API::CallNode invocation) {
  exists(invocation.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(invocation.asCfgNode().(CallNode).getNode().getKwargs())
}

// Define predicate to check if autoescape is explicitly set to False
predicate hasAutoescapeDisabled(API::CallNode invocation) {
  invocation.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

// Retrieves API nodes for Jinja2's main constructor classes
private API::Node jinja2CoreConstructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode tmplConstructorCall
where
  // Identify calls to Jinja2 constructor methods
  tmplConstructorCall = jinja2CoreConstructors().getACall()
  and
  // Filter out calls using variable arguments
  not usesVariableArguments(tmplConstructorCall)
  and
  (
    // Case 1: autoescape parameter is not explicitly defined
    not exists(tmplConstructorCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape is explicitly set to False
    hasAutoescapeDisabled(tmplConstructorCall)
  )
select tmplConstructorCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."