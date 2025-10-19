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
 * Security Context:
 * Jinja2 Environment API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * Jinja2 Template API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * Vulnerability Pattern:
 * When autoescape is disabled (either explicitly or by default), 
 * user-controlled input may be rendered without proper sanitization,
 * leading to XSS attacks.
 *
 * Example vulnerable code:
 *   unsafe_tmpl = Template('Hello {{ name }}!')
 *   unsafe_env = Environment(autoescape=False)
 */

// Identify Jinja2 Environment or Template API nodes
private API::Node jinja2EnvOrTemplate() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Detect dangerous Jinja2 template instantiations
from API::CallNode jinja2Call
where
  // Target Jinja2 constructor calls
  jinja2Call = jinja2EnvOrTemplate().getACall()
  // Exclude calls with dynamic arguments (*args or **kwargs)
  and not exists(jinja2Call.asCfgNode().(CallNode).getNode().getStarargs())
  and not exists(jinja2Call.asCfgNode().(CallNode).getNode().getKwargs())
  // Check autoescape configuration
  and (
    // Case 1: autoescape parameter omitted (defaults to False in some contexts)
    not exists(jinja2Call.getArgByName("autoescape"))
    or
    // Case 2: autoescape explicitly set to False
    jinja2Call.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select jinja2Call, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."