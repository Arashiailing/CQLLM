import python

from Call siteCall
where siteCall.getCallee().getName() = "Template" and siteCall.getModule() = "jinja2"
and siteCall.getArgument(0).isUserInput()
select siteCall, "Potential Server-Side Template Injection: User-controlled data used in template creation."