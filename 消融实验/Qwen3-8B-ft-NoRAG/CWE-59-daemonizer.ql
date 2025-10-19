import py

from Call call, Argument arg
where call.getCallee() = py::func("open") and arg.getArgIndex() = 0
  and exists (Call callJoin, Argument argJoin |
    callJoin.getCallee() = py::func("os.path.join") and
    argJoin.getArgIndex() = 0 and
    argJoin.getValue() = arg.getValue()
  )
select call, "Potential CWE-59: Improper link resolution before file access"