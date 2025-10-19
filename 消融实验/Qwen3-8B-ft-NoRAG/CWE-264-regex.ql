import python

from Call, Arg
where Call.getCallee() = "re.compile"
  and Call.getArg(0) = Arg
  and Arg.isUserInput()
  and not exists (Call2 where Call2.getCallee() = "re.escape" and Call2.getArg(0) = Arg)
select Call, "Potential Regex Injection: User input directly used in regex pattern without escaping."