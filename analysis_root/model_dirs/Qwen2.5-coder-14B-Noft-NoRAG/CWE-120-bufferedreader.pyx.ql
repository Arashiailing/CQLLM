import python

from CallExpr call, Function func
where func.getName() = "memcpy" and
      call.getArgument(0).getType() instanceof PointerType and
      call.getArgument(1).getType() instanceof PointerType and
      call.getArgument(2).getType() instanceof IntegerType and
      not exists(CallExpr checkCall |
        checkCall.getCallee().getName() = "strlen" and
        checkCall.getArgument(0) = call.getArgument(1) and
        checkCall.getEnclosingStmt().getAfters().contains(call)
      )
select call, "This memcpy call may lead to a buffer overflow because the size of the input buffer is not checked."