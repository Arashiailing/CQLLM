import python
/**
 * @name PathInjection
 * @description Detects potential Path Injection vulnerabilities by identifying unsafe file path construction patterns.
 */
from Call call, Argument arg
where call.getTarget().getName() = "open"
  and call.getArguments().size() >= 1
  and arg.getValue().getType().getName() = "str"
  and call.getLocation().getFile().endsWith(".py")
  and call.getArguments().select(a | a.getIndex() == 0).exists(a |
    a.getValue().getStringLiteral().contains("..") or
    a.getValue().getStringLiteral().contains("/") or
    a.getValue().getStringLiteral().contains("\\"))
select call.getLocation(), "Potential Path Injection vulnerability detected through direct use of untrusted input in file path construction."