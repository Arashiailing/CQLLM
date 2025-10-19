import python

from Call getCall, Variable userInputVar, String str
where getCall.getSelector().getName() = "get"
    and getCall.getReceiver().getType().getName() = "ImmutableMultiDict"
    and getCall.getTarget() = userInputVar
    and (exists(Call concatCall where concatCall.getOperator() = "+" and concatCall.getLhs() = str and concatCall.getRhs() = userInputVar)
        or exists(Call formatCall where formatCall.getMethodName() = "format" and formatCall.getArg(0) = userInputVar and formatCall.getTarget() = str))
select str