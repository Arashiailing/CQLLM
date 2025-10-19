import python
import regex

from Call call, String pattern
where call.getDecl().getName() in ("re.match", "re.search", "re.sub", "re.compile")
  and pattern = call.getArg(1)
  and pattern.matches(".*([a-zA-Z]+).*\\1.*")
select pattern, "Potential ReDoS vulnerability due to repeated subpatterns."