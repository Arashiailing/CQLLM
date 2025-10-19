import python

from Call call
where call.getCallee().getFunction().getName() in ("loads", "load") and 
      call.getCallee().getFunction().getModule().getName() in ("pickle", "cloudpickle", "marshal") and 
      call.getParameter(0).isUserInput()
select call, "Unsafe deserialization of user-controlled data."