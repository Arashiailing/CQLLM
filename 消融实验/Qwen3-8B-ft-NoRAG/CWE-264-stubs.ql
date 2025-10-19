import python

from Call import Call
where Call.getSelector().getName() = "system" or Call.getSelector().getName() = "run"
  and Call.getArg(0).getValue().contains("user_input")
select Call, "Potential CWE-264: Insecure use of system command with user input"