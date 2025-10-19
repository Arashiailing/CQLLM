import python

from Call call
where call.getCalleeName() = "os.setuid" or call.getCalleeName() = "os.setgid" or call.getCalleeName() = "subprocess.run" and call.getArg(0).isStringLiteral() and call.getArg(0).getValue() = "sudo"
select call, "Potential CWE-264: Improper Privilege Management detected"