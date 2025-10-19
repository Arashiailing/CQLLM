import python

/**
 * TarSlip vulnerability query.
 * Detects instances where user-controlled data is used in path expressions.
 */
from Call call, StringLiteral path
where call.getCallee().getName() = "tar" and
      call.getArgument(0) = path and
      path.getValue().matches("%.*%.*")
select call, "Uncontrolled data used in path expression: " + path.getValue()