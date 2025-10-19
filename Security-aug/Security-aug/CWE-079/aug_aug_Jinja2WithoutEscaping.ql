/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects usage of Jinja2 templates with 'autoescape=False'
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

/**
 * References:
 * Jinja2 Environment API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * Jinja2 Template API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * Security Note: The autoescape parameter controls HTML escaping in Jinja2 templates.
 * When set to False or not specified in certain contexts, it can lead to XSS vulnerabilities.
 * Example vulnerable code:
 *   unsafe_tmpl = Template('Hello {{ name }}!')  // autoescape defaults to False
 *   unsafe_env = Environment(autoescape=False)   // autoescape explicitly disabled
 */

// Helper to identify Jinja2 Environment or Template API nodes
private API::Node jinja2Constructor() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Main query logic to detect dangerous Jinja2 template instantiations
from API::CallNode jinja2Call
where
  // Verify this is a call to Jinja2 Environment or Template constructor
  jinja2Call = jinja2Constructor().getACall() and
  // Exclude calls with dynamic arguments (*args or **kwargs)
  not exists(jinja2Call.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(jinja2Call.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // Case 1: autoescape parameter is not specified (defaults to False in some contexts)
    not exists(jinja2Call.getArgByName("autoescape"))
    or
    // Case 2: autoescape parameter is explicitly set to False
    jinja2Call.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select jinja2Call, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."