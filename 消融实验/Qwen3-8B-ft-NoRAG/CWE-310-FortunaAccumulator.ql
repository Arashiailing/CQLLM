import semmle.code.python.frameworks.PyFunctionCall
import semmle.code.python.frameworks.PyModule

from PyFunctionCall call, PyModule module
where module.getName() = "hashlib"
  and call.getFunctionName() in ("md5", "sha1", "sha224", "sha384", "sha512")
select call, "Weak sensitive data hashing detected using " + call.getFunctionName() + "."