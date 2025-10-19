import python

/**
 * @name XML external entity expansion
 * @description Parsing user input as an XML document with external
 * entity expansion is vulnerable to XXE attacks.
 */
from CalledMethod cm
where cm.getMethodName() = "parse" or cm.getMethodName() = "fromstring"
  and cm.getReceiverType().getName() = "ElementTree"
  and not (cm.getArguments().has(Arg(arg | arg.getValue().getStringValue() = "False")))
select cm.getLocation(), "XXE vulnerability: Parsing user input as XML without disabling external entity resolution."