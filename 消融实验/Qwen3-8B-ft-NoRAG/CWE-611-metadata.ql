import python

from Call call
where (call.getMethod().getName() = "parse" and call.getModule().getName() = "xml.etree.ElementTree") or
      (call.getMethod().getName() = "fromstring" and call.getModule().getName() = "xml.etree.ElementTree") or
      (call.getMethod().getName() = "parse" and call.getModule().getName() = "lxml.etree") or
      (call.getMethod().getName() = "fromstring" and call.getModule().getName() = "lxml.etree")
select call, "Potential XXE vulnerability due to parsing user input with external entity expansion enabled."