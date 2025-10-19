import python

/**
 * Detects path traversal vulnerabilities by identifying unsafe string concatenation
 * in file path construction patterns.
 */
from Call callee, StringLiteral arg
where callee.getName() = "os.path.join" 
  and callee.getArgument(0).isStringLiteral() 
  and callee.getArgument(1).isStringLiteral()
  and (callee.getArgument(1).getValue().contains("..") or callee.getArgument(1).getValue().contains("/"))
select callee, "Potential path traversal vulnerability through unsafe path concatenation"