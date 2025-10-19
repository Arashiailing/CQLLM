import python

from Call call
where call.getCallee().getName() = "re.sub"
  and call.getArg(1).getValue() = "<.*?>"
select call, "This regex may not properly filter HTML tags, leading to XSS."