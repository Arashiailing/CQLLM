/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects potential cross-site scripting vulnerabilities
 *              caused by using jinja2 templates with 'autoescape=False'.
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
 * Jinja 2 API Documentation:
 * Environment class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * Template class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 * 
 * Security Note: The autoescape parameter is supported by both Environment and Template constructors
 * Vulnerable code example:
 *   unsafe_tmpl = Template('Hello {{ name }}!', autoescape=False)
 */

// Identify Jinja2's primary constructor API nodes
private API::Node jinja2CoreConstructor() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Predicate to check if a call uses star arguments (*args)
private predicate usesStarArgs(API::CallNode call) {
  exists(call.asCfgNode().(CallNode).getNode().getStarargs())
}

// Predicate to check if a call uses keyword arguments dictionary (**kwargs)
private predicate usesKwargs(API::CallNode call) {
  exists(call.asCfgNode().(CallNode).getNode().getKwargs())
}

// Predicate to check if autoescape is explicitly set to False
private predicate autoescapeSetToFalse(API::CallNode call) {
  call.getKeywordParameter("autoescape")
      .getAValueReachingSink()
      .asExpr()
      .(ImmutableLiteral)
      .booleanValue() = false
}

from API::CallNode jinja2ApiCall
where
  // Verify this is a call to a Jinja2 constructor
  jinja2ApiCall = jinja2CoreConstructor().getACall()
  and
  // Exclude calls with variable arguments
  not usesStarArgs(jinja2ApiCall)
  and
  // Exclude calls with keyword argument dictionaries
  not usesKwargs(jinja2ApiCall)
  and
  (
    // Case 1: autoescape parameter is not explicitly set
    not exists(jinja2ApiCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape is explicitly set to False
    autoescapeSetToFalse(jinja2ApiCall)
  )
select jinja2ApiCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."