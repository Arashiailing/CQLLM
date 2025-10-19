import python

/**
 * @name XML external entity expansion
 * @description Parsing user input as an XML document with external
 * entity expansion is vulnerable to XXE attacks.
 * @id py/_xml
 */
from Call call
where
  (call.getCallee() = "xml.etree.ElementTree.fromstring" or
   call.getCallee() = "xml.etree.ElementTree.parse" or
   call.getCallee() = "lxml.etree.fromstring" or
   call.getCallee() = "lxml.etree.parse")
  and not (call.getArgs().exists(arg |
    (arg.getName() = "parser" and
     arg.getType().getName() = "xml.etree.ElementTree.XMLParser" and
     arg.getExpr().getValue().hasProperty("resolve_entities") and
     arg.getExpr().getValue().getProperty("resolve_entities").getValue() = false) or
    (arg.getName() = "parser" and
     arg.getType().getName() = "lxml.etree.XMLParser" and
     arg.getExpr().getValue().hasProperty("resolve_entities") and
     arg.getExpr().getValue().getProperty("resolve_entities").getValue() = false)))
select call, "Potential XXE vulnerability: XML parsing without disabling external entity expansion"