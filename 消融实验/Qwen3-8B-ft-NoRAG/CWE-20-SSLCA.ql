import python

from Call c
where c.getKind() = "call"
  and (c.getFunctionName() = "input" or c.getFunctionName() = "sys.stdin.read" or c.getFunctionName() = "urllib.parse.parse_qs")
select c, "Potential CWE-20: Improper Input Validation"