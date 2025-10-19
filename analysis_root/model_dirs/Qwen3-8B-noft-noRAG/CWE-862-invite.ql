import python
import semmle.code.python.frameworks.flask.Flask

from Route route, Function function
where route.getHandler() = function
    and not (function.hasDecorator("flask.login_required") 
        or function.hasDecorator("flask.current_user") 
        or function.hasCallTo("flask.g.user") 
        or function.hasCallTo("flask.current_user.id"))
select function, "The function lacks necessary authorization checks for the associated route."