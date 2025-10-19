import python

from Call import Call
where Call.get_method().getName() = "system" or Call.get_method().getName() = "call" or Call.get_method().getName() = "run" or Call.get_method().getName() = "check_output"
and Call.get_argument(0).isString()
select Call, "Potential command injection via command execution with untrusted input."