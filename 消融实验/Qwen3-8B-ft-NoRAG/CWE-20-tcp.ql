import py

from Call call
where call.getFunction().getName() = "input" or call.getFunction().getName() = "sys.stdin.read" or call.getFunction().getName() = "open" or call.getFunction().getName() = "socket.recv"
select call, "Potential CWE-20: Improper Input Validation"