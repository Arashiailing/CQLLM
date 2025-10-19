/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects Jinja2 template instantiations with 'autoescape=False'
 *              which can enable cross-site scripting (XSS) attacks.
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
 * Note: autoescape parameter applies to both Environment and Template constructors
 * Example vulnerable code:
 *   unsafe_tmpl = Template('Hello {{ name }}!')
 *   unsafe_env = Environment(autoescape=False)
 */

// Helper to identify Jinja2 Environment or Template API nodes
private API::Node getJinja2EnvOrTemplateApi() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Main query logic to detect dangerous Jinja2 template instantiations
from API::CallNode jinja2Call
where
  // Verify this is a Jinja2 Environment or Template constructor call
  jinja2Call = getJinja2EnvOrTemplateApi().getACall() and
  // Exclude calls with dynamic arguments (*args or **kwargs)
  not exists(jinja2Call.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(jinja2Call.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // Case 1: autoescape parameter is omitted (defaults to False in some contexts)
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