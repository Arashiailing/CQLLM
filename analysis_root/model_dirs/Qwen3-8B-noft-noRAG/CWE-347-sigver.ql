import python
import semmle.code.java.frameworks.common

from MethodCall m, StringLiteral weakHashFunc, StringLiteral strongHashFunc
where (m.getExpression().toString() = "hashlib." + weakHashFunc)
    and weakHashFunc in ["md5", "sha1"]
    and exists(
        Call c
        | c.getMethodName() = "verify"
        and c.getArgument(0).getValue().asString() = m.getExpression().toString()
        and c.getArgument(1).getValue().asString() = "expected_hash_value"
    )
select m, "Potential CWE-347: Improper verification of cryptographic signature using weak hash function " + weakHashFunc