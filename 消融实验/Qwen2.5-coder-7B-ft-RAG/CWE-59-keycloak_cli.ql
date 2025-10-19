/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description nan
 * @id py/keycloak_cli
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 7.5
 * @tags security
 *       experimental
 *       external/cwe/cwe-059
 */

import python
import experimental.semmle.python.security.KeycloakCli
import KeycloakCliFlow::PathGraph

from KeycloakCliFlow::PathNode source, KeycloakCliFlow::PathNode sink
where KeycloakCliFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Keycloak CLI follows a symbolic link at $@.", source.getNode(),
  "this location"