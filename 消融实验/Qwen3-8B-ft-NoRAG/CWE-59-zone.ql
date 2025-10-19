import python

from Call call
where (call.getTarget() = openFunction() or
       call.getTarget() = osPathJoinFunction() or
       call.getTarget() = PathWriteTextFunction() or
       call.getTarget() = PathReadTextFunction() or
       call.getTarget() = PathOpenFunction())
  and call.getArgument(0).getValue().matches('..[\\\\/]')
select call, "Potential CWE-59: Path traversal in file operation"