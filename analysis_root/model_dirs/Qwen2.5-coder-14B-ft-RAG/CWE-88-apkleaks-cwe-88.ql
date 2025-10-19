/**
 * @name CWE-88: Improper Neutralization of Argument Delimiters in a Command ('Argument Injection')
 * @description nan
 * @kind problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/apkleaks-cwe-88
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode injection_sink, string dangerous_api
where
  (
    dangerous_api = "subprocess.Popen" and
    injection_sink = API::moduleImport("subprocess").getMember("Popen").getACall()
  )
  or
  (
    dangerous_api = "os.system" and
    injection_sink = API::builtin("os.system").getACall()
  )
  or
  (
    dangerous_api = "os.popen" and
    injection_sink = API::builtin("os.popen").getACall()
  )
  or
  (
    dangerous_api = "popen2.popen2" and
    injection_sink = API::moduleImport("popen2").getMember("popen2").getACall()
  )
  or
  (
    dangerous_api = "popen2.popen3" and
    injection_sink = API::moduleImport("popen2").getMember("popen3").getACall()
  )
  or
  (
    dangerous_api = "popen2.popen4" and
    injection_sink = API::moduleImport("popen2").getMember("popen4").getACall()
  )
  or
  (
    dangerous_api = "commands.getstatusoutput" and
    injection_sink = API::moduleImport("commands").getMember("getstatusoutput").getACall()
  )
  or
  (
    dangerous_api = "commands.getoutput" and
    injection_sink = API::moduleImport("commands").getMember("getoutput").getACall()
  )
select injection_sink,
  "$@ may be called with a user-provided argument, which could result in command injection.", injection_sink,
  dangerous_api