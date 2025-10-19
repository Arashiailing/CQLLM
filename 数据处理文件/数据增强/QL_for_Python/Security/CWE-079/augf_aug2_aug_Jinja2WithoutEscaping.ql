/**
 * @name Jinja2 templating with autoescape=False
 * @description Identifies Jinja2 template instantiations where 'autoescape=False'
 *              is explicitly set or omitted, potentially enabling XSS attacks.
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

// Main query logic to detect dangerous Jinja2 template instantiations
from API::CallNode vulnerableCall
where
  // Identify Jinja2 Environment or Template constructor calls
  (
    vulnerableCall = API::moduleImport("jinja2").getMember("Environment").getACall()
    or
    vulnerableCall = API::moduleImport("jinja2").getMember("Template").getACall()
  ) and
  // Exclude calls with dynamic arguments (*args or **kwargs)
  not exists(vulnerableCall.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(vulnerableCall.asCfgNode().(CallNode).getNode().getKwargs()) and
  // Check autoescape parameter conditions
  (
    // Case 1: autoescape parameter omitted (defaults to False in some contexts)
    not exists(vulnerableCall.getArgByName("autoescape"))
    or
    // Case 2: autoescape parameter explicitly set to False
    vulnerableCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select vulnerableCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."