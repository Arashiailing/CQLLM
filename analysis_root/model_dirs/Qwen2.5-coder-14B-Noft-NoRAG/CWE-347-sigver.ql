import python

/**
 * This query detects instances of CWE-347: Improper Verification of Cryptographic Signature.
 * It looks for cases where cryptographic signatures are not verified or are incorrectly verified.
 */

from Call call, Function func
where func.getName() = "verify" and
      call.getCallee() = func and
      not exists(Call c | c.getCallee().getName() = "update" and c.getCaller() = call)
select call, "This call to verify does not update the signature before verification."