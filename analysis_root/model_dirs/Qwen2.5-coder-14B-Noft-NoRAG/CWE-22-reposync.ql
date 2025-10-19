import python

/**
 * This query detects instances where user-controlled data is used in a path expression,
 * which can lead to CWE-22: Path Traversal.
 */
from Call call, Arg arg
where call.getCallee().getName() = "open" or call.getCallee().getName() = "os.path.join"
  and arg.getAnIndex() = 0
select arg, "User-controlled data is used in a path expression, which can lead to CWE-22: Path Traversal."