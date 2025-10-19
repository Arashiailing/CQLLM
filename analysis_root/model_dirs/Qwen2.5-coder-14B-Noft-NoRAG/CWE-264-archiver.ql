import python

/**
 * This query detects CWE-264: TarSlip vulnerability in Python code.
 * The vulnerability occurs when an archive extraction process does not properly
 * validate the paths of the files being extracted, allowing attackers to
 * overwrite arbitrary files on the system.
 */

from Call call, Arg arg
where call.getCallee().getName() = "extractall"
  and arg = call.getArgument(0)
select arg, "Potentially vulnerable to TarSlip attack due to lack of path validation in extractall."