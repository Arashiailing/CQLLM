import python

/**
 * This query detects the use of insufficiently random values in a security context.
 */
from Call call, Function func
where func.getName() = "random" and
      call.getCallee() = func and
      call.getCaller().isSecuritySensitive()
select call, "This call to random() may be used in a security context that requires unpredictable numbers."