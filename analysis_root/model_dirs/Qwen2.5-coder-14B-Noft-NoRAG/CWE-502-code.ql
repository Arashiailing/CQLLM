import python

/**
 * CWE-502: Deserialization of user-controlled data
 */
from Call call, DataFlow::Node source, DataFlow::Node sink
where
  // Find calls to deserialization functions
  call.getCallee().getName() = "loads" and
  // Check if the deserialization function is called with user-controlled data
  DataFlow::localFlow(source, call.getArgument(0)) and
  // Check if the deserialized data is used in a sensitive operation
  DataFlow::localFlow(call.getResult(), sink)
select call, "Deserializing user-controlled data may allow attackers to execute arbitrary code."