import python

/**
 * CWE-326: Use of weak cryptographic key
 * This query detects the use of cryptographic keys that are too small.
 */

from CallExpr call, Expr keySize, StringLiteral algo
where call.getCallee().getName() = "generate_key"
  and call.getArgument(0) = algo
  and algo.getValue() = "AES"
  and call.getArgument(1) = keySize
  and keySize instanceof IntegerLiteral
  and keySize.asInt() < 128
select call, "Use of weak cryptographic key (AES with key size less than 128 bits)"