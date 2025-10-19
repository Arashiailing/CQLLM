import python

from Call get_call, Call redirect_call
where (get_call.getFunctionName() = "request.args.get" or
       get_call.getFunctionName() = "request.form.get" or
       get_call.getFunctionName() = "request.cookies.get")
  and redirect_call.getFunctionName() in ["flask.redirect", "django.http.HttpResponseRedirect", "webob.response.Response.redirect"]
  and redirect_call.getArgument() = get_call.getReturnValue()
select redirect_call, "Potential URL redirection based on unvalidated user input"