import python

from PyFunctionCall call
where call.getFunction().getName() = "extractall" and
      (call.getFunction().getModule() = "zipfile" or call.getFunction().getModule() = "tarfile") and
      not exists (call.getParameters() as param where param.getName() = "path")
select call, "Potential CWE-264: TarSlipQuery vulnerability due to untrusted archive extraction without path parameter."