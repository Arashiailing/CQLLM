/**
 * @name CWE-330: Use of Insufficiently Random Values
 * @description The product uses insufficiently random numbers or values in a security context that depends on unpredictable numbers.
 * @id py/packet
 */
import python
import semmle.python.security.InsufficientRandomness

from FunctionCall call
where call.getCalleeName() = "random.randint"
select call, "Use of 'random.randint' which may not provide sufficient randomness for cryptographic purposes."