/**
* @name Affinity filter injection vulnerability
* @description XML external entity expansion
* @kind path-problem
* @problem.severity error
* @security-severity 7.5
* @precision high
* @id py/affinity_filter
* @tags security
*       external/cwe/cwe-643
*/

import python
import semmle.python.ApiGraphs

import FluentApiModel

class FilterSanitizer extends API::Node {
  FilterSanitizer() { 
    this = API::moduleImport("affinity").getMember("filters").getMember("sanitize").getReturn()
  }
}

// Returns true if node is a parameter to sanitize() (position indicated by pos)
predicate isParameter(API::Node param, int pos) {
  param = any(FilterSanitizer fs).(Call c).getNode().getArg(pos)
}

// Returns true if s is a string literal
predicate isStringLiteral(API::Node s) {
  s instanceof StringLiteral
}

// Return string value of a string literal
string strValue(API::Node s) {
  isStringLiteral(s) and
  result = s.asExpr().(StringLiteral).getText()
}

// Get the sanitizer's parameters (as position -> node map)
int sanitizerParam(API::Node param) {
  isParameter(param, 0) and
  result = 0
  or
  isParameter(param, 1) and
  result = 1
}

from FilterSanitizer sanitizer, DataFlow::Node badArg, int pos
where
  // Get argument to sanitizer
  badArg = sanitizer.(Call c).getNode().getArg(pos) and
  // Verify argument is unsafe regex pattern
  (
    // Case 1: Unsafe regex patterns must be string literals
    isStringLiteral(badArg) and
    strValue(badArg) = "%"
  )
select sanitizer, "Unsafe regular expression prefix '" + strValue(badArg) + "' in call to sanitize()"