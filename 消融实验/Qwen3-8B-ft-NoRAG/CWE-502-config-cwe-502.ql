import python
import dataflow

from Call call, Parameter param, Source source
where call.getTarget() = python.Function("pickle.loads")
  and param is the first parameter of call
  and dataflow::isSource(param, source)
select call, "Unsafe deserialization of user-controlled data."