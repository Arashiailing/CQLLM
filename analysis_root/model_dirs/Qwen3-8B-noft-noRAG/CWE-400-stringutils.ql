import python
import codeql

/**
 * Detects potential Polynomial ReDoS vulnerabilities by analyzing regular expressions.
 */
from FunctionCall fc, StringLiteral sl
where (fc.getName() = "compile" or 
       fc.getName() = "search" or 
       fc.getName() = "findall" or 
       fc.getName() = "finditer" or 
       fc.getName() = "match" or 
       fc.getName() = "sub" or 
       fc.getName() = "split")
  and fc.getCallee().getFullyQualifiedName() = "re"
  and fc.getParameter(0).getValue() = sl
  and (
    // Check for multiple consecutive quantifiers (*, +,?)
    codeql.StringRegex.matches(sl.getValue(), ".*([*+?]{2,}).*") or
    // Check for non-capturing groups with repetition
    codeql.StringRegex.matches(sl.getValue(), ".*$$[^$$]*$$ {2,}.+") or
    // Check for large repetition counts
    codeql.StringRegex.matches(sl.getValue(), ".*$$[^$$]*$$\{5,\}.*") or
    // Check for complex alternations
    codeql.StringRegex.matches(sl.getValue(), ".*$$[^$$]*$$\|[^$$]*$$\|[^$$]*$$.*") or
    // Check for excessive dot-star patterns
    codeql.StringRegex.matches(sl.getValue(), ".*\.\*\.\*.+") 
  )
select sl, "Potential Polynomial ReDoS vulnerability detected in regex pattern."