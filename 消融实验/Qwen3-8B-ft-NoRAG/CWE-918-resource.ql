import python

from Call call, Argument arg
where (call.getFunction().getName() = "requests.get" or
       call.getFunction().getName() = "urllib.request.urlopen" or
       call.getFunction().getName() = "http.client.HTTPConnection.request") and
      arg = call.getArgument(0) and
      arg.getValue().getInput()
select call, "Potential SSRF vulnerability: user-controlled URL in network request"