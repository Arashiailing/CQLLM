import python

/**
 * CWE-125: Out-of-bounds Read
 */
from ArrayAccess arrayAccess
where arrayAccess.getIndex().getStartColumn() = 0
select arrayAccess, "This array access might be out-of-bounds."