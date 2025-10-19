import python

/**
 * @name CWE-20: Improper Input Validation (Command Injection)
 */
query CWE_20_CommandInjection() {
  // Find calls to subprocess functions with shell=True
  Call call <- 
    (Call
      (FunctionDeclaration
        (Name "subprocess.call")
      )
      (Argument (StringLiteral "shell=True"))
    )

  // Check if any argument contains untrusted user input
  StringExpression arg <- call.getArguments()
  
  // Filter for arguments that may contain user-controlled data
  // This is a simplified example; actual implementation would need more precise analysis
  select call, "Potential command injection via subprocess call with shell=True"
}