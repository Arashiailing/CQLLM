import python

/**
 * A query to detect CWE-502: Deserialization of user-controlled data.
 */
from DeserializationCall deserializationCall, DataFlow::Node userControlledData, DataFlow::Node deserializationData
where deserializationCall.getTarget().hasName("loads") or deserializationCall.getTarget().hasName("load")
  and DataFlow::localFlow(userControlledData, deserializationData)
select deserializationCall, "Deserializing user-controlled data may allow attackers to execute arbitrary code."