import py

/**
 * Detects potential command injection vulnerabilities by identifying calls to dangerous functions 
 * that construct commands using untrusted input.
 */
from CallExpr call, FunctionDecl func
where 
    (func.name = "subprocess.run" or 
     func.name = "subprocess.call" or 
     func.name = "subprocess.check_call" or 
     func.name = "subprocess.check_output" or 
     func.name = "os.system") and
    call.getCallee() = func and
    exists(Param param | 
        call.getParams()[param] and 
        param.getType().is(py.String) and
        param.getSource().getOrigin().isUserInput()
    )
select call.getLocation(), "Potential command injection vulnerability: function $func may be using untrusted input in a command argument.", func