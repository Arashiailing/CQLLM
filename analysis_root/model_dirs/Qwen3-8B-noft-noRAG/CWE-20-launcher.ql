import python

/**
 * @name CWE-20: Command Injection
 * @description Detects command injection vulnerabilities by identifying unsafe use of command execution functions with untrusted inputs.
 */
predicate isDangerousCommandExecutionFunction(Function f) {
    f = subprocess.run Or
        f = subprocess.call Or
        f = os.system Or
        f = os.popen Or
        f = shlex.split Or
        f = commands.getoutput Or
        f = subprocess.check_output
}

from Call call, StringLiteral cmdStr, Argument arg
where 
    isDangerousCommandExecutionFunction(call.function) 
    and arg.value = cmdStr 
    and cmdStr.toString() contains "input()" Or 
       cmdStr.toString() contains "request.args" Or 
       cmdStr.toString() contains "getvalue()" Or 
       cmdStr.toString() contains "raw_input()" Or 
       cmdStr.toString() contains "sys.stdin"
select call, "Potential command injection vulnerability: Unvalidated input used in command execution."