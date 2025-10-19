```ql
import python

from Call call
where
  (call.getTarget().getSymbol().getName() = "parse" and
   call.getFunction().getQualifiedName() = "xml.etree.ElementTree.parse" and
   (call.getArgument(1).isNull() or
    (call.getArgument(1).getType().getName() = "xml.etree.ElementTree.XMLParser" and
     call.getArgument(1).getSymbol().getMember("resolve_entities").getValue() = true))) or
  (call.getTarget().getSymbol().getName() = "fromstring" and