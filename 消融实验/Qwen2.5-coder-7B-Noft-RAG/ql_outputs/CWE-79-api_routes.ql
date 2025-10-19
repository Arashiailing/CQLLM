/**
* @name Reflected server-side cross-site scripting
*
@description Writing user input directly to a web page allows f
    or a cross-site scripting vulnerability.
*
@id py/api_routes
*/
import python
import semmle.python.web.routes.APIRoute
from APIRoute route
    where route.hasUserInput()
    select route, "Potential reflected XSS vulnerability due to user input."