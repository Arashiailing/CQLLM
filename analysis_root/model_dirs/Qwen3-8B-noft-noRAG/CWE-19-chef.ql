import python

/**
 * @name Detects command injection vulnerabilities (CWE-19)
 */
from Call call, StringLiteral cmdStr, Variable inputVar
where 
    // Identify calls to dangerous functions that execute system commands
    (call.getCallee() = "os.system" or
     call.getCallee() = "subprocess.call" or
     call.getCallee() = "subprocess.run" or
     call.getCallee() = "subprocess.check_output") and
    
    // Check if the first argument is a string literal containing unescaped variables
    exists (StringLiteral sl | 
        call.getArg(0) = sl and
        sl.getValue().contains(inputVar.getName()) and
        not sl.getValue().matches("^[a-zA-Z0-9\\_\\-\\./\\$]+$")) and
    
    // Ensure the variable is user-controlled (e.g., from input sources)
    inputVar.isFromInput()
select call.getLocation(), "Potential command injection vulnerability detected: untrusted input directly used in system command execution."