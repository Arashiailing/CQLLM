import python

/**
 * @name unsafe-shell-command-construction
 * @description Detects the use of user-controlled data in shell command construction.
 */
from Call call, Argument arg
where 
  call.getCallee().getModule() = "subprocess" and 
  (call.getName() = "call" or 
   call.getName() = "check_call" or 
   call.getName() = "run" or 
   call.getName() = "Popen") and 
  arg.getIndex() = 0 and 
  arg.getValue().hasUserInput()
select call, "Potential unsafe shell command construction: user input used directly in command arguments."