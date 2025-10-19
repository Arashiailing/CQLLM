/**
* @name Improper Input Validation (CWE-20)
* @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
* @kind path-problem
* @problem.severity error
* @security-severity 7.8
* @sub-severity low
* @precision high
* @id py/registerservlet
* @tags correctness
*       security
*       external/cwe/cwe-20
*/

import python
import semmle.python.ApiGraphs

from ClassObject servletClass, int portNumber, ServletRegistration reg
where
  reg = servletClass.(HttpServletRegistration).getARegister()
  and
  (
    exists(reg.getPort()) and portNumber = reg.getPort()
    or
    not exists(reg.getPort())
    and
    portNumber =
      any(HttpServer s |
          s.getAServlet() = servletClass and
          s.getHttpPort() = portNumber
      )
  )
select servletClass,
  "Servlet " + servletClass.getName() + " registered at port " + portNumber + "."