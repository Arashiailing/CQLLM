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

/*
 * References:
 * Jinja2 Environment API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * Jinja2 Template API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * Note: autoescape parameter is valid for both Environment and Template constructors
 * Example vulnerable code:
 *   unsafe_tmpl = Template('Hello {{ name }}!')
 *   unsafe_env = Environment(autoescape=False)
 */

// Helper to identify Jinja2 Environment or Template API nodes
private API::Node jinja2EnvOrTemplate() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Main query logic to detect dangerous Jinja2 template instantiations
from API::CallNode templateCall
where
  // Check if this is a call to Jinja2 Environment or Template constructor
  templateCall = jinja2EnvOrTemplate().getACall() and
  // Exclude calls with dynamic arguments (*args or **kwargs)
  not exists(templateCall.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(templateCall.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // Case 1: autoescape parameter is not specified (defaults to False in some contexts)
    not exists(templateCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape parameter is explicitly set to False
    templateCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select templateCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."