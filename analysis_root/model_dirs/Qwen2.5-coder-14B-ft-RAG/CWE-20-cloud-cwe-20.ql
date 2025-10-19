/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @id py/cloud-cwe-20
 * @problem.severity error
 * @tags reliability
 */

import python
import semmle.python.Concepts

from HttpServer::Request req, HttpServer::Response resp, string message
where
  (
    resp = req.getResponse() and
    exists(HttpServer::Sink s |
      s.isHeader() and
      message = "HTTP header" and
      s.getLocation().flowsTo(resp.getHeader())
    )
    or
    message = "body"
  ) and
  not req.getSecurityResult().isAllowed()
select req.getRequestLocation(), "$@ processed via a $@ is returned to the client.", req,
  "User-provided", message