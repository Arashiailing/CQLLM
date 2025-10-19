import python

/**
 * @name ReflectedXss
 * @description Detects potential reflected XSS vulnerabilities by identifying unescaped user input in HTML context.
 */
from Call call, Argument arg
where call.getMethod().getName() = "print" and
      arg.getValue().getAsString() = "user_input" and
      call.getFilePath().getFileName() = "example.py"
select call, "Potential reflected XSS vulnerability: unescaped user input in HTML context."