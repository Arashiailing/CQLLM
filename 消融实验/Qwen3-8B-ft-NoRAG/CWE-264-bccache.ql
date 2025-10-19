import py

from Call call
where 
  (call.getFunction().getName() = "loads" and call.getFunction().getModule() = "pickle") 
  or 
  (call.getFunction().getName() = "load" and call.getFunction().getModule() = "pickle")
select call, "Potential unsafe deserialization using pickle module"