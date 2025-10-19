import python
import semmle.code.common.querying
import semmle.code.python.strings

from MethodInvoke invoke, String pattern, String replacement
where invoke.getTarget().getName() = "sub" or invoke.getTarget().getName() = "subn"
  and (invoke.getQualifierType().isSubtypeOf("re._sre.SRE_Pattern") or invoke.getQualifierType().isSubtypeOf("re.Pattern"))
  and invoke.getArgs().size() >= 2
  and invoke.getArgs()[0].getValue().toString() = pattern
  and invoke.getArgs()[1].getValue().toString() = replacement
  and pattern.toString() matches "<.*?>"  // Simple tag matching that may miss edge cases
select invoke, "Potential reflected XSS due to unsafe HTML filtering regex"