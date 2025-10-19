import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/mistune
 */
from Call site, StringLiteral, Parameter
where 
    (site.getMethod().getName() = "add" and site.getArgument(0).getType().getName() = "str") or
    (site.getMethod().getName() = "write" and site.getArgument(0).getType().getName() = "str") or
    (site.getMethod().getName() = "render" and site.getArgument(0).getType().getName() = "str")
    and site.getArgument(0).getValue().matches("<%=.*%>")
select site, "Potential reflected XSS vulnerability: unescaped user input detected in HTML output."