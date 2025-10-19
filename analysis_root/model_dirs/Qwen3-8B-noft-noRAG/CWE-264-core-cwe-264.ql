import python

from Call call, Argument arg
where 
    call.getCallee().getName() in ["subprocess.run", "subprocess.call", "os.system"] and
    arg.getArgumentIndex() = 0 and
    arg.getValue().hasUserInput()
select call, "Potential command injection vulnerability detected: user input is directly passed to a shell execution function."