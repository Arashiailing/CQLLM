import python

/**
 * Detects path injection vulnerabilities by identifying unsafe path concatenation patterns.
 */
from MethodCall mc, Arg arg
where 
    (mc.getMethodName() = "os.path.join" or 
     mc.getMethodName() = "pathlib.PurePath.joinpath" or 
     mc.getMethodName() = "__truediv__") and
    arg.getArgPosition() = 0 and
    exists(Argument a | a.getArgPosition() = 1 and a.getValue().toString().matches(".*\\.\$$.*"))
select mc.getLocation(), "Potential path traversal via unsafe path concatenation"