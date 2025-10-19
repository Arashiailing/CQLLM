import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects improper authentication by identifying potential issues where identity verification is lacking.
 */
from MethodCall mc
where mc.getMethodName() = "getpass" or mc.getMethodName() = "input" or mc.getMethodName() = "raw_input"
let value = mc.getArgument(0)
from Assignment a
where a.getLeftHandSide().getName() = value.getName()
and a.getRightHandSide() = mc
from Call authCall
where authCall.getMethodName() = "authenticate" or authCall.getMethodName() = "login" or authCall.getMethodName() = "validate"
and authCall.getArguments() contains a.getLeftHandSide()
and not (exists (IfStmt ifs where ifs.getCondition() = authCall.getExpression()))
select authCall, "Potential improper authentication: User input directly used in authentication without proper validation."