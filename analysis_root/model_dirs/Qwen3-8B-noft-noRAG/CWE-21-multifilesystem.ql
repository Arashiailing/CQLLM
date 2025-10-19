import python

/**
 * @name Path Injection (CWE-21)
 * @description Detects potential path injection vulnerabilities by identifying unsafe usage of user-controlled inputs in file paths.
 */
from Call call, StringLiteral sl, Parameter param
where 
    call.getTarget().getName() = "os.path.join" or 
    call.getTarget().getName() = "pathlib.PurePosixPath.__init__" or 
    call.getTarget().getName() = "pathlib.PureWindowsPath.__init__"
    and 
    param.isArgumentOf(call) and 
    sl.isInCallSite(call) and 
    sl.getValue().matches(".*\.\./") and 
    param.getOrigin() = sl
select call, "Potential path traversal vulnerability detected due to unvalidated input in file path construction."