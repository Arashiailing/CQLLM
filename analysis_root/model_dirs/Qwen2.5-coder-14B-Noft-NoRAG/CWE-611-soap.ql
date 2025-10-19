import python

from FunctionCall call, Function func
where func.getName() = "parse" and
      call.getTarget() = func and
      call.getArgument(0).getType().toString() = "xml.etree.ElementTree.ElementTree"
select call, "This function call is vulnerable to CWE-611: XML external entity expansion."