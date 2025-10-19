import python

/**
 * CWE-502: Deserialization of user-controlled data
 */
from DeserializationCall deserializationCall
where deserializationCall.getTarget().(Class).getName() = "pickle"
select deserializationCall, "Deserializing user-controlled data may allow attackers to execute arbitrary code."