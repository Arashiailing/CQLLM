/**
 * @name Jinja2 templating with autoescape=False
 * @description Detects Jinja2 template instantiations with 'autoescape=False'
 *              which may enable cross-site scripting (XSS) vulnerabilities.
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
 * Security Context:
 * Jinja2's autoescape parameter controls HTML escaping behavior. When disabled:
 * - Environment(autoescape=False) explicitly disables escaping
 * - Template() defaults to autoescape=False in certain contexts
 * Both scenarios can expose applications to XSS attacks through unescaped output.
 * 
 * References:
 * - Jinja2 Environment API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * - Jinja2 Template API: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 */

// Identifies Jinja2 Environment or Template constructor APIs
private API::Node jinja2TemplateConstructor() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// Checks if a call contains dynamic arguments (*args/**kwargs)
private predicate containsDynamicArgs(API::CallNode call) {
  exists(call.asCfgNode().(CallNode).getNode().getStarargs())
  or
  exists(call.asCfgNode().(CallNode).getNode().getKwargs())
}

// Checks if autoescape parameter is explicitly set to False
private predicate isAutoescapeExplicitlyFalse(API::CallNode call) {
  call.getKeywordParameter("autoescape")
    .getAValueReachingSink()
    .asExpr()
    .(ImmutableLiteral)
    .booleanValue() = false
}

// Detects vulnerable Jinja2 instantiations
from API::CallNode riskyJinja2Instantiation
where
  // Verify target is Jinja2 Environment/Template constructor
  riskyJinja2Instantiation = jinja2TemplateConstructor().getACall()
  
  // Exclude calls with dynamic arguments (*args/**kwargs)
  and not containsDynamicArgs(riskyJinja2Instantiation)
  
  // Identify autoescape misconfigurations
  and (
    // Case 1: autoescape parameter omitted (defaults to False in Template)
    not exists(riskyJinja2Instantiation.getArgByName("autoescape"))
    
    // Case 2: autoescape explicitly disabled
    or isAutoescapeExplicitlyFalse(riskyJinja2Instantiation)
  )
select riskyJinja2Instantiation, "Jinja2 template configured with autoescape=False may allow XSS attacks"