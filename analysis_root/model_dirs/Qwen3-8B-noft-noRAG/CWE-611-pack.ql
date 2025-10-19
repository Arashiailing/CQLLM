import python

from Call call
where call.getTarget().getModule() = "xml.etree.ElementTree"
  and (call.getName() = "parse" or call.getName() = "fromstring")
  and exists(Argument arg |
    call.getArguments()[0] = arg
    and arg.isString()
    and arg.isUserInput()
  )
select call, "Potential XXE vulnerability: parsing user input as XML without disabling external entity resolution."