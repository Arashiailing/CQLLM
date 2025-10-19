import python

/**
 * CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 */

/**
 * Finds potential buffer overflows in Python code.
 */
from ArrayAccess arrAccess
where arrAccess.isArrayElementAccess() and
      not arrAccess.isArrayLengthCheck()
select arrAccess, "This array access may lead to a buffer overflow."