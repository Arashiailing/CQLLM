import py

from Call call
where call.getCallee().getName() = "chmod"
  and call.getArguments().size() > 0
  and call.getArguments()[0].getValue().getIntegerLiteral().getValue() = 0o666
select call, "Insecure permissions set to 0o666 using chmod."