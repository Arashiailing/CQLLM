/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @id py/cli-cwe-295
 * @tags security
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode call
where
  call = API::moduleImport("urllib").getMember("request").getMember("urlopen").getACall()
select call, "Use of urllib.request.urlopen"