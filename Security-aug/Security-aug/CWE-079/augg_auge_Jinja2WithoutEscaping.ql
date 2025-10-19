/**
 * @name Jinja2 templating with autoescape=False
 * @description Identifies cross-site scripting risks from Jinja2 templates
 *              when autoescaping is explicitly disabled or defaults to False.
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
 * - Jinja2 Environment API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Jinja2 Template API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * The autoescape parameter controls HTML escaping. When disabled (False),
 * untrusted input rendered in templates may execute malicious scripts,
 * leading to XSS vulnerabilities.
 *
 * Vulnerable pattern examples:
 *   env = Environment(autoescape=False)  # Explicitly disabled
 *   tmpl = Template("{{ user_input }}")  # Defaults to False in some configs
 */

// Define Jinja2 classes that accept the autoescape parameter
private API::Node jinja2AutoescapeClass() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Analyze Jinja2 class instantiations
from API::CallNode jinja2Call
where
  // Target calls to Jinja2 core classes
  jinja2Call = jinja2AutoescapeClass().getACall() and
  // Exclude calls with dynamic arguments that might hide autoescape setting
  not exists(jinja2Call.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(jinja2Call.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // Scenario 1: autoescape parameter omitted (may default to False)
    not exists(jinja2Call.getArgByName("autoescape"))
    or
    // Scenario 2: autoescape explicitly set to False
    jinja2Call.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select jinja2Call, "Jinja2 template with autoescape=False creates XSS vulnerability risk."