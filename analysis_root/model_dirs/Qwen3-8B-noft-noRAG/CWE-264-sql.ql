import python
import semmle.code.scala.query.LanguageQueries

from MethodCall mc, StringLiteral str, Variable v
where 
  mc.getMethodName() = "execute" or mc.getMethodName() = "executescript" or 
  (mc.getMethodName() = "execute" and mc.getQualifier().getName() = "cursor") or 
  (mc.getMethodName() = "execute" and mc.getQualifier().getName() = "connection")
  
  and exists(
    str.getStringValue().matches(".*'([^']*)'.*") 
    and v.getName() = str.getStringValue().getSubstring(3, str.getStringValue().length()-4)
    and mc.getArguments()[0].getValue().getStringValue().contains(v.getName())
  )
select mc.getLocation(), "Potential SQL injection vulnerability via string concatenation in SQL query"