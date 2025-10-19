import python

/** @predicate */
from MethodCall mc
where 
  (mc.getMethodName() = "parse" and mc.getCallee().getName() = "xml.etree.ElementTree.parse") or
  (mc.getMethodName() = "fromstring" and mc.getCallee().getName() = "xml.etree.ElementTree.fromstring") or
  (mc.getMethodName() = "XMLParser" and mc.getCallee().getName() = "lxml.etree.XMLParser")
select mc, "Potential XXE vulnerability: XML parsing with external entity expansion enabled"