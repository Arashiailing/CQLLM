import python

/**
 * CWE-125: Out-of-bounds Read
 * Detects cases where data is read past the end or before the beginning of the intended buffer.
 */
from ArrayAccess arrayAccess, Array array
where arrayAccess.getArray() = array
  and arrayAccess.getIndex() > array.getLength()
select arrayAccess, "This array access reads past the end of the buffer."