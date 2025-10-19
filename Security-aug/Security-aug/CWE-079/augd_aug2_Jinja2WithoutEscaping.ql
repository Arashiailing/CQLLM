/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects the use of Jinja2 templates with 'autoescape=False',
 *              which can lead to cross-site scripting vulnerabilities.
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
 * Jinja2 API Documentation:
 * Environment class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * Template class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 * 
 * Security Note: The 'autoescape' parameter is critical for both Environment and Template constructors.
 * Vulnerable code example:
 *   unsafe_template = Template('Hello {{ username }}!', autoescape=False)
 */

// Define a helper to retrieve Jinja2's main constructor API nodes
private API::Node getJinja2CoreConstructors() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode jinja2ApiCall
where
  // Verify this is a call to a Jinja2 constructor
  jinja2ApiCall = getJinja2CoreConstructors().getACall()
  and
  // Filter out calls using variable arguments (*args)
  not exists(jinja2ApiCall.asCfgNode().(CallNode).getNode().getStarargs())
  and
  // Filter out calls using keyword argument dictionaries (**kwargs)
  not exists(jinja2ApiCall.asCfgNode().(CallNode).getNode().getKwargs())
  and
  (
    // Case 1: autoescape parameter is not explicitly set (defaults to False)
    not exists(jinja2ApiCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape parameter is explicitly set to False
    jinja2ApiCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select jinja2ApiCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."