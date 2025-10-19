/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/registerservlet
 */

import python
import semmle.python.ApiGraphs

from APICall servletRegistration, string method, string className where
  (
    servletRegistration = API::moduleImport("javax.servlet.http.HttpServlet").getMember("registerServlet").getACall()
    and
    method = "registerServlet"
    and
    className = "HttpServlet"
  )
  or
  (
    servletRegistration = API::moduleImport("javax.servlet.ServletContext").getMember("addServlet").getACall()
    and
    method = "addServlet"
    and
    className = "ServletContext"
  )
select servletRegistration.asExpr(),
  "Uncontrolled registration of a servlet through " + className + "." + method + "() could potentially exhaust server resources."