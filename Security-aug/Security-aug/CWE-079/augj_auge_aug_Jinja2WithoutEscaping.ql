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
 * Disabling autoescaping (explicitly or by default) allows rendering of user-controlled
 * input without sanitization, creating XSS attack vectors.
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
from API::CallNode dangerousJinjaCall
where
  // Target Jinja2 constructor calls
  dangerousJinjaCall = jinja2EnvOrTemplate().getACall()
  // Exclude calls with dynamic arguments (*args or **kwargs)
  and not exists(dangerousJinjaCall.asCfgNode().(CallNode).getNode().getStarargs())
  and not exists(dangerousJinjaCall.asCfgNode().(CallNode).getNode().getKwargs())
  // Evaluate autoescape configuration
  and (
    // Case 1: autoescape parameter omitted (defaults to False in some contexts)
    not exists(dangerousJinjaCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape explicitly set to False
    dangerousJinjaCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select dangerousJinjaCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."