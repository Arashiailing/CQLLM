import python

/**
 * Detects potential command injection vulnerabilities by identifying unsafe usage of command execution functions.
 */
predicate isDangerousCommandExecution(Call call) {
  // Check for os.system with user-controlled input
  if (call.getFunction().getName() = "os.system") {
    let cmdArg = call.getArgs()[0]
    return cmdArg.isStringLiteral() == false
  }

  // Check for subprocess calls with shell=True and untrusted input
  if (call.getFunction().getModule() = "subprocess" and 
      call.getFunction().getName() in ["run", "call", "check_output", "Popen"]) {
    let args = call.getArgs()
    let shellParam = args.find { arg | arg.getName() = "shell" }
    if (shellParam!= null and shellParam.isTrue()) {
      let cmdArg = args.find { arg | arg.getName()!= "shell" }
      return cmdArg.isStringLiteral() == false
    }
  }

  false
}

from Call call
where isDangerousCommandExecution(call)
select call, "Potential command injection vulnerability detected via direct user input to command execution function"