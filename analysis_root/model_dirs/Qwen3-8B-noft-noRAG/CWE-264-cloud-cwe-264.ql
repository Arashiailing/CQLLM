import python
import semmle.code.cpp.dataflow.DataFlow

from StringLiteral sl, File f
where 
  sl.getValue().matches("password|token|secret|key|cred.*") and 
  f.isRead() and 
  f.getName().matches("\\.(yml|json|cfg|conf|env)$")
select sl, "Detected potential cleartext storage of sensitive data in configuration file $f$", f