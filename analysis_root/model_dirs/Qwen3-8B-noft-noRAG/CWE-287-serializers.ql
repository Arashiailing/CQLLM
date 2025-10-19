import python
import semmle.code.cpp.dataflow.DataFlow

from Call site, Argument arg
where
  site.getMethodName() = "loads" and
  site.getDeclaringType().getName() = "pickle.Unpickler" or
  site.getDeclaringType().getName() = "yaml.YAMLObjectLoader" or
  site.getDeclaringType().getName() = "json.JSONDecoder"
  and
  arg.getValue().getType().getName() = "str" and
  arg.isFromUserInput()
select site, "Potential CWE-287: Improper authentication due to untrusted deserialization input"