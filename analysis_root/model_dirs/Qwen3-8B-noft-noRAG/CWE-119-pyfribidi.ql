import python

from Call call
where call.getMethodName() = "__getitem__"
  and call.getArgs()[0].getType() instanceof List
  and call.getArgs()[1].getType() instanceof Int
  and call.getArgs()[1].getValue() > call.getArgs()[0].getLength()
select call, "Potential out-of-bounds access in list indexing"