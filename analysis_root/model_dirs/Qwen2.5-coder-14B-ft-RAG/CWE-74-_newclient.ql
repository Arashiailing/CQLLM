/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

import python
import semmle.python.ApiGraphs

// Helper function to retrieve the appropriate API module member for a given template engine
private API::Node temporary_name_function(string mod, string function) {
  // Attempt to get the specified function from the provided module name
  result = API::moduleImport(mod).getMember(function)
}

// Main query logic starts here
from Call c, string mod, string function
where
  // Check if the current call matches one of the known unsafe template functions
  (
    // Case 1: Jinja2 environment rendering with unsafe autoescape setting
    c = temporary_name_function("jinja2", "Environment").getACall() and
    c.getArg(0, "autoescape").asExpr().(ImmutableLiteral).booleanValue() = false
  )
  or
  (
    // Case 2: Jinja2 template rendering with unsafe autoescape setting
    c = temporary_name_function("jinja2", "Template").getACall() and
    not exists(c.getArgByName("autoescape"))
    or
    c.getKeywordParameter("autoescape")
     .getAValueReachingSink()
     .asExpr()
     .(ImmutableLiteral)
     .booleanValue() = false
  )
// Select the call node along with a descriptive message
select c, "Unsafe template rendering with " + mod + "." + function + "."