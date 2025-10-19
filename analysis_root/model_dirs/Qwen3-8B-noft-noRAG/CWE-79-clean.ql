import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/clean
 */

from Call call, Arg arg, FunctionDecl func
where 
  call.getMethod().getName() = "print" or 
  call.getMethod().getName() = "write" or 
  call.getMethod().getName() = "render_template_string"
  and exists(
    arg.getValue() as StringLiteral,
    (arg.getValue() as StringLiteral).getRawValue() like "%{%" or 
    (arg.getValue() as StringLiteral).getRawValue() like "'%'" or 
    (arg.getValue() as StringLiteral).getRawValue() like '"%' or 
    (arg.getValue() as StringLiteral).getRawValue() like "%}%" or 
    (arg.getValue() as StringLiteral).getRawValue() like "%%") 
  )
select call, "Potential reflected XSS due to direct user input in HTML context."