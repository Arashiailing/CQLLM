import python

/**
 * @name CWE-20: Improper Input Validation
 */
query CWE_20_CommandInjection() {
  // Identify calls to functions that can execute shell commands with untrusted inputs
  select {
    Call c
    where c.getCalleeName() in [
      "subprocess.run",
      "subprocess.check_output",
      "subprocess.call",
      "subprocess.Popen",
      "os.system",
      "eval",
      "exec"
    ]
    and c.getArgument(0).getType().isString()
    and exists (
      String s
      where s = c.getArgument(0)
      and s.getSource() is Variable v
      and v.isFromUserInput()
    )
    and (c.getArgumentCount() == 0 or c.getArgument(1).getBoolValue() == true)  // Check for shell=True if applicable
  }
}