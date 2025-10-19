import python

/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description Detects improper link resolution before file access, which can lead to path traversal vulnerabilities.
 */
from Call call, Arg arg
where 
    call.getCallee().getSymbolName() in ["open", "io.open", "File.open"] and
    arg.getIndex() = 0 and
    exists (StringLiteral sl | arg.getExpr() = sl) or
    exists (Variable v | arg.getExpr() = v and v.isGlobal()) or
    exists (FunctionCall fc | arg.getExpr() = fc and fc.toString() like "%join%")
select call.getLocation(), "Potential CWE-59 vulnerability: Unsanitized file path parameter used in file operation."