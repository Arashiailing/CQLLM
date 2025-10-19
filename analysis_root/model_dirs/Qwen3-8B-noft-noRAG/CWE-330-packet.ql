import python

/**
 * @name CWE-330: Weak Sensitive Data Hashing
 * @description Detects the use of insufficiently random values in sensitive data hashing contexts.
 */
from MethodCall mc
where mc.getMethodName() = "hash"
  and mc.getReceiver().getType().getName() = "hashlib"
  and exists(
    CallExpr ce
    where ce = mc.getArgument(0)
      and ce.getCallee().getModule().getName() = "random"
      and ce.getCallee().getName() in ["randint", "randrange", "random", "uniform", "gauss"]
  )
select mc, "Potential CWE-330: Weak random value used in sensitive data hashing."