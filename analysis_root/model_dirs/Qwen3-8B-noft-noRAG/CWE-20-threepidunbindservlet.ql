import semmle.code.java.CodeqlCore
import semmle.python.Python
import semmle.python.strings.StringUtils

/**
 * Query to detect potential Path Injection vulnerabilities (CWE-20)
 * by identifying unsafe path construction patterns.
 */
from CallExpr call, StringLiteral userParam, Expr pathPart
where 
    call.getMethodName() = "os.path.join" 
    and call.getNumArgs() >= 2 
    and exists(
        Arg arg1, Arg arg2 |
        call.getArg(0) = arg1 and 
        arg1.getValue().matches("<string>.*</string>") and 
        call.getArg(1) = arg2 and 
        arg2.getValue().matches("<string>.*</string>")
    )
select call, "Potential Path Injection vulnerability detected: unsafe path construction with unvalidated inputs."