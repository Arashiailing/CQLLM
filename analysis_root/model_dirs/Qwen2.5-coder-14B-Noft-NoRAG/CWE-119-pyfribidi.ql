import python

/**
 * This query detects CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer.
 * It looks for instances where a buffer is accessed out of bounds.
 */

from ArrayAccess arrayAccess
where arrayAccess.isArrayOutOfBounds()
select arrayAccess, "This array access is out of bounds, which may lead to CWE-119."