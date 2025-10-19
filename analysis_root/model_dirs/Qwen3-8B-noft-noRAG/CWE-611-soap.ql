import python

/**
 * @name XML external entity expansion
 * @description Parsing user input as an XML document with external
 * entity expansion is vulnerable to XXE attacks.
 * @id py/soap
 */
from Call call, MethodDecl method
where 
  (method.getName() = "parse" and 
   call.getModule().getName() = "xml.etree.ElementTree" and 
   call.getTarget() = method) or
  (method.getName() = "fromstring" and 
   call.getModule().getName() = "lxml.etree" and 
   call.getTarget() = method)
select call, "Potential XXE vulnerability: XML parsing without disabling external entity expansion"