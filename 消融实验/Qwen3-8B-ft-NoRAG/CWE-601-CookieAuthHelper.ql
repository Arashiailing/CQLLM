import python

from Call redirectCall, Call userInputCall
where redirectCall.getTarget() = "flask.redirect" and
      redirectCall.getArgument(0) = userInputCall.getArgument(0) and
      (userInputCall.getTarget() = "flask.request.args.get" or
       userInputCall.getTarget() = "flask.request.form.get" or
       userInputCall.getTarget() = "flask.request.values.get")
select userInputCall, "Potential URL redirection from unvalidated user input"