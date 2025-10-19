import python

/**
 * This query detects potential instances of CWE-502: Deserialization of user-controlled data.
 * It looks for calls to deserialization functions with user-controlled input.
 */

from FunctionCall deserializeCall, Argument userControlledArg
where deserializeCall.getCallee().getName() in ["pickle.load", "json.loads", "yaml.safe_load"]
  and userControlledArg = deserializeCall.getArgument(0)
  and userControlledArg.getType() instanceof UserInputType
select deserializeCall, "Deserializing user-controlled data may allow attackers to execute arbitrary code."