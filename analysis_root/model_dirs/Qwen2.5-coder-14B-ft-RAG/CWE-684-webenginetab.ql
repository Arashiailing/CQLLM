/**
 * @name CWE-684: Incorrect Provision of Specified Functionality
 * @description This query identifies HTTP redirects where user input is used in constructing redirect URLs,
 *              which could potentially enable attackers to control the target URL of the redirection.
 * @id py/webenginetab
 */

// Import Python analysis libraries
import python

// Import data flow analysis utilities for URL redirection detection
import semmle.python.security.dataflow.UrlRedirectQuery

// Import data flow graph representation for tracking propagation paths
import UrlRedirectFlow::PathGraph

// Define variables for tracking source (input origin) and sink (destination point)
from UrlRedirectFlow::PathNode userInputOrigin, UrlRedirectFlow::PathNode redirectDestination

// Verify existence of data flow path between user input and redirect location
where UrlRedirectFlow::flowPath(userInputOrigin, redirectDestination)

// Select results including sink node, complete path details, and descriptive message
select redirectDestination.getNode(), userInputOrigin, redirectDestination, 
  "URL redirection depends on a $@.", userInputOrigin.getNode(), "user-provided value"