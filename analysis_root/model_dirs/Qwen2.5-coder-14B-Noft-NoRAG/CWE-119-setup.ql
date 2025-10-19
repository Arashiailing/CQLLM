import python

/**
 * CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 */

/**
 * Finds instances where a buffer is accessed out of bounds.
 */
from ArrayAccess arrayAccess, Array array
where arrayAccess.getArray() = array and
      arrayAccess.getIndex() > array.getSize() or
      arrayAccess.getIndex() < 0
select arrayAccess, "Potential out-of-bounds access to array."