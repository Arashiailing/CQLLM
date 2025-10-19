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
 * This query identifies unsafe Jinja2 template configurations where autoescaping is disabled.
 * Jinja2's Environment and Template constructors both accept an 'autoescape' parameter.
 * When autoescaping is disabled (either explicitly set to False or omitted),
 * user-provided input may not be properly escaped, creating XSS vulnerabilities.
 * 
 * API References:
 * - Environment: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 */

// Check if the function call uses variable arguments (*args or **kwargs)
predicate hasVariableArguments(API::CallNode funcCall) {
  exists(funcCall.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(funcCall.asCfgNode().(CallNode).getNode().getKwargs())
}

// Determine if autoescape parameter is explicitly set to False
predicate isAutoescapeDisabled(API::CallNode funcCall) {
  funcCall.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

// Get API nodes for Jinja2's main constructor classes
private API::Node getJinja2Constructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Check if autoescape parameter is missing in the function call
predicate isAutoescapeParameterMissing(API::CallNode funcCall) {
  not exists(funcCall.getArgByName("autoescape"))
}

from API::CallNode jinja2ConstructorCall
where
  // Target calls to Jinja2 constructor methods
  jinja2ConstructorCall = getJinja2Constructors().getACall()
  and
  // Exclude calls using variable arguments
  not hasVariableArguments(jinja2ConstructorCall)
  and
  // Identify unsafe configurations: either autoescape is missing or explicitly disabled
  (
    isAutoescapeParameterMissing(jinja2ConstructorCall)
    or
    isAutoescapeDisabled(jinja2ConstructorCall)
  )
select jinja2ConstructorCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."