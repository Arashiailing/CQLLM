/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects Jinja2 template configurations where autoescaping is disabled,
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
 * This query identifies unsafe Jinja2 template configurations that disable autoescaping.
 * Jinja2's Environment and Template classes both accept an 'autoescape' parameter.
 * When autoescaping is disabled (either explicitly set to False or omitted),
 * user-provided input is not properly escaped, creating XSS vulnerabilities.
 * 
 * API Documentation:
 * - Environment class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 */

// Helper predicate to identify API calls that use variable arguments (*args or **kwargs)
predicate hasVariableArguments(API::CallNode apiCall) {
  exists(apiCall.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(apiCall.asCfgNode().(CallNode).getNode().getKwargs())
}

// Helper predicate to check if autoescape parameter is explicitly set to False
predicate autoescapeExplicitlyDisabled(API::CallNode apiCall) {
  apiCall.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

// Retrieves API nodes for Jinja2's primary constructor classes
private API::Node getJinja2Constructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode jinja2ConstructorInvocation
where
  // Identify calls to Jinja2 constructor methods
  jinja2ConstructorInvocation = getJinja2Constructors().getACall()
  and
  // Exclude calls using variable arguments which might contain autoescape settings
  not hasVariableArguments(jinja2ConstructorInvocation)
  and
  (
    // Check if autoescape parameter is missing (defaults to False in some contexts)
    not exists(jinja2ConstructorInvocation.getArgByName("autoescape"))
    or
    // Check if autoescape is explicitly set to False
    autoescapeExplicitlyDisabled(jinja2ConstructorInvocation)
  )
select jinja2ConstructorInvocation, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."