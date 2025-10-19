import python

/**
 * This query detects CWE-264: TarSlip vulnerability in Python code.
 * It looks for cases where the `tarfile` module is used to extract files
 * without proper validation of the file paths.
 */

from Call call, Argument arg
where call.getCallee().getName() = "extractall"
  and call.getEnclosingCallable() instanceof Function
  and arg = call.getArgument(0)
  and arg.getType() instanceof StringType
select call, "Potential TarSlip vulnerability detected: 'extractall' method called with a string argument."