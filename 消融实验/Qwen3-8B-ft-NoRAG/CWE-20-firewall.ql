import python

from Input input, Call call
where input.getSource() = call.getArgument(0)
  and not (call.getMethod().getName() = "isInteger" or call.getMethod().getName() = "isAlpha" or call.getMethod().getName() = "isNumeric")
select call, "This call uses unvalidated input."