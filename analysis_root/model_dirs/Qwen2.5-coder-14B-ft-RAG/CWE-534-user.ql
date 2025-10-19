/**
 * @deprecated
 * @name CWE-534: DEPRECATED: Information Exposure Through Debug Log Files
 * @description DEPRECATED. Use py/debug-log-info-instead.
 * @kind problem
 * @problem.severity recommendation
 * @id py/user-controlled-log-messages
 * @tags security
 *       external/cwe/cwe-312
 */

import python
import semmle.python.Concepts

from Function f, string prefix
where
  not f.isTest() and
  (
    exists(HttpServer::requestHandler(f)) or
    exists(HttpClient::clientRequest(f))
  ) and
  prefix in ["debug", "trace", "info"] and
  f.getName() = prefix and
  not exists(HttpClient::clientRequest(f) and HttpServer::serverResponse(f))
select f,
  "This function appears to be a custom '" + prefix +
    "' method used to handle HTTP requests and responses."