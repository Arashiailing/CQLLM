import python

from Call import Call
where Call.getFullyQualifiedName() = "xml.etree.ElementTree.parse" and
      Call.getArgument(1).getName() = "allow_dtd" and
      Call.getArgument(1).getValue() = true
select Call, "Potential XXE vulnerability via ElementTree.parse with allow_dtd=True"

from Call import Call
where Call.getFullyQualifiedName() = "lxml.etree.fromstring" and
      Call.getArgument(1).getName() = "resolve_entities" and
      Call.getArgument(1).getValue() = true
select Call, "Potential XXE vulnerability via lxml.fromstring with resolve_entities=True"