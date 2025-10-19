/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision medium
 * @id py/auth-bypass
 * @tags security
 *       external/cwe/cwe-287
 */

import python
import semmle.python.Concepts
import FluentApiConcepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

from AuthBypassFlow::PathNode source, AuthBypassFlow::PathNode sink, Http::Client::Request req
where
  AuthBypassFlow::flowPath(source, sink)
  and
  req = source.getNode().(Http::Client::RequestWithBody::unparsedContent) and
  not Tests::testCode()
select req, source, sink, "HTTP request depends on a $@.", source.getNode(),
  "user-provided value"