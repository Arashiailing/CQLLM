import py

from Call call
where call.getKind() = "ListIndexAccess"
  and call.getArgument(0).isInteger()
  and call.getArgument(0).getValue() >= 0
  and call.getArgument(0).getValue() < call.getContainer().getLength()

or call.getKind() = "StringIndexAccess"
  and call.getArgument(0).isInteger()
  and call.getArgument(0).getValue() >= 0
  and call.getArgument(0).getValue() < call.getContainer().getLength()

or call.getKind() = "StringSlice"
  and call.getArgument(0).isInteger()
  and call.getArgument(0).getValue() >= 0
  and call.getArgument(0).getValue() < call.getContainer().getLength()
  and call.getArgument(1).isInteger()
  and call.getArgument(1).getValue() >= 0
  and call.getArgument(1).getValue() < call.getContainer().getLength()