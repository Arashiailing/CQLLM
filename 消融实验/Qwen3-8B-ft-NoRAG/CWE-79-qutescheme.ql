import python

from Call call, Argument arg
where call.getCallee().getName() = "print" and arg.getValue().getAsString() like "%{user_input}%"
select call, "Potential Reflected XSS due to direct output of user input."