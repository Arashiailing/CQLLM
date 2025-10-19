import python

/**
 * @name CWE-59: Improper Link Resolution Before File Access
 */
from Call call
where call.getTarget().getName() = "open" and
      call.getArgument(0).getType().getName() = "str" and
      call.getArgument(0).getQualifiedName().contains("os.path") and
      not exists(Call normCall |
          normCall.getTarget().getName() = "os.path.normpath" or
          normCall.getTarget().getName() = "os.path.abspath" and
          normCall.getArgument(0) = call.getArgument(0))
select call, "Potential CWE-59 vulnerability: Direct use of unnormalized path from os.path.* functions."