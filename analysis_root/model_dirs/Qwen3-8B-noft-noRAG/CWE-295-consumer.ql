import semmle.python.dataflow.PythonDataFlow
import semmle.code.cpp.frameworks.Framework

from ModuleImport, Call
where 
  ModuleImport.module = "requests" and 
  (Call.getTarget().getName() = "get" or Call.getTarget().getName() = "post") and 
  Call.getArg(0).getValue().toString() = "verify" and 
  Call.getArg(0).getValue().toString() = "False"
select Call, "CWE-295: Improper Certificate Validation - Request without certificate validation"

from ModuleImport, Call
where 
  ModuleImport.module = "urllib3" and 
  Call.getTarget().getName() = ".PoolManager" and 
  Call.getArg(0).getValue().toString() = "cert_reqs" and 
  Call.getArg(0).getValue().toString() = "CERT_NONE"
select Call, "CWE-295: Improper Certificate Validation - Urllib3 without certificate verification"