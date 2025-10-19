import python

from Call import Call
where Call.getFunction().getModule() = "requests"
  and (Call.getFunction().getName() = "get" or Call.getFunction().getName() = "post")
  and Call.getArgument("verify").getValue() = false

select Call, "This call to requests.get or requests.post has verify=False, which may allow MITM attacks."