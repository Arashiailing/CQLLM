import python

from FunctionCall fc, Argument arg
where (fc.getName() = "eval" or fc.getName() = "exec")
  and fc.getArguments().size() > 0
  and arg.getValue() is String
  and arg.getValue().getBaseName() = "input"
select fc