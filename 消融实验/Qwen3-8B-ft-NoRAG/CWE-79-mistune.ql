import semmle.code.py.Python
import semmle.code.py.security.XSS

from FunctionCall fc
where fc.getQualifiedName() = "mistune.Markdown"
  and fc.getArgument(0).isUserInput()
select fc, "Reflected XSS vulnerability in mistune Markdown rendering."