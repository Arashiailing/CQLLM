import python
import dataflow

/**
 * @name Deserialization of user-controlled data
 * @description Deserializing user-controlled data may allow attackers to execute arbitrary code.
 * @id py/bookmarkmanager
 */
from Call call, Argument arg
where call.getCallee().getName() = "loads"
  and call.getModule().getName() = "pickle"
  and arg.getIndex() = 0
  and exists(Source src) where src.getLocation() = arg.getValue().getLocation()
select call, "Unsafe deserialization of user-controlled data using pickle.loads"