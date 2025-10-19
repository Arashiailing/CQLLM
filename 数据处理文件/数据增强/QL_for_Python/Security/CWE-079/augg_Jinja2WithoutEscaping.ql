/**
 * @name Jinja2 templating with autoescape=False
 * @description Using jinja2 templates with 'autoescape=False' can
 *              cause a cross-site scripting vulnerability.
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
 * Jinja 2 Documentation Reference:
 * - Environment class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Template class: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * Security Note:
 * While not explicitly documented, the 'autoescape' parameter is valid when constructing
 * Template objects directly. For example:
 *
 * unsafe_tmpl = Template('Hello {{ name }}!')  // Defaults to autoescape=False
 * safe_tmpl = Template('Hello {{ name }}!', autoescape=True)  // Explicitly safe
 */

// Private predicate to retrieve Jinja2 Environment or Template API nodes
private API::Node getJinja2EnvOrTemplate() {
  // Match either the Environment class from jinja2 module
  result = API::moduleImport("jinja2").getMember("Environment")
  // Or the Template class from jinja2 module
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Private predicate to check if a call has unsafe autoescape configuration
private predicate hasUnsafeAutoescape(API::CallNode templateCall) {
  // Ensure the call doesn't use *args or **kwargs which could hide the autoescape parameter
  not exists(templateCall.asCfgNode().(CallNode).getNode().getStarargs()) and
  not exists(templateCall.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // Case 1: autoescape parameter is not provided (defaults to False)
    not exists(templateCall.getArgByName("autoescape"))
    // Case 2: autoescape parameter is explicitly set to False
    or
    templateCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
}

// Main query to detect Jinja2 template instantiations with unsafe autoescape settings
from API::CallNode templateCall
where
  // The call must be to Jinja2 Environment or Template constructor
  templateCall = getJinja2EnvOrTemplate().getACall() and
  // The call must have unsafe autoescape configuration
  hasUnsafeAutoescape(templateCall)
select templateCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."