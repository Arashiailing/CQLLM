/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects potential cross-site scripting vulnerabilities
 *              caused by using Jinja2 templates with 'autoescape=False'.
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
 * Reference: Jinja 2 API Documentation
 * - Environment class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * The autoescape parameter is critical for security. When disabled (False),
 * user-provided data rendered in templates won't be automatically escaped,
 * potentially leading to XSS vulnerabilities.
 *
 * Example vulnerable code:
 *   unsafe_tmpl = Template('Hello {{ name }}!', autoescape=False)
 *   env = Environment(autoescape=False)
 */

// Identify the core Jinja2 classes that accept the autoescape parameter
private API::Node jinja2CoreClass() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Analyze calls to Jinja2 core classes
from API::CallNode templateCall
where
  // Verify the call is to a Jinja2 core class
  templateCall = jinja2CoreClass().getACall() and
  // Exclude calls with dynamic arguments (*args or **kwargs)
  // which might hide the autoescape parameter
  not exists(templateCall.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(templateCall.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // Case 1: autoescape parameter is not specified (defaults to False in some configurations)
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