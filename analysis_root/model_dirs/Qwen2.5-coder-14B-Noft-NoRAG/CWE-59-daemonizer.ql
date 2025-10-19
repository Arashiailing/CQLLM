import python

/**
 * CWE-59: Improper Link Resolution Before File Access ('Link Following')
 *
 * This query detects potential instances of CWE-59, where the program
 * does not properly resolve symbolic links before accessing a file.
 */

from Call call, Argument arg
where call.getCallee().getName() = "os.path.join" and
      arg = call.getArgument(0) and
      arg.getType().getName() = "str"
select arg, "This argument may lead to CWE-59: Improper Link Resolution Before File Access ('Link Following')."