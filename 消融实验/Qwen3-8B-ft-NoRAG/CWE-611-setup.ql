import python

from Call import Call
where (Call.getTarget().getName() = "parse" and Call.getFunction().getModule() = "lxml.etree") or 
      (Call.getTarget().getName() = "fromstring" and Call.getFunction().getModule() = "xml.etree.ElementTree")
select Call, "Potential XXE vulnerability in XML parsing with user-controlled input."