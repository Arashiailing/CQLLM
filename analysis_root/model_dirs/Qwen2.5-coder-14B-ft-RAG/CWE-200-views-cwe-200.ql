/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind problem
 * @tags security
 *       external/cwe/cwe-200
 * @problem.severity error
 * @security-severity 5.0
 * @sub-severity high
 * @precision high
 * @id py/views-cwe-200
 */

import python
import semmle.python.views.Security

from HttpServerResponse response, TaintKind taintType
where
  // Check if the response contains sensitive data
  (
    response.containsSensitiveData(taintType)
    or
    // Or if there is an unsafe injection flow to the response
    (
      exists(HttpServerRequest request | 
        request.unsafeInjectionFlowTo(response, _)
      )
      and
      taintType = external()
    )
  )
select response, "This $@ may contain $@.", response,
  "server-side HTTP response", taintType.toString()