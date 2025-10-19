/**
 * @name Multiple imports on one line
 * @description Defining multiple imports on one line makes code more difficult to read;
 *              PEP8 states that imports should usually be on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

import python

// This query detects import statements that violate PEP 8's recommendation of one import per line.
// It focuses on standard import statements (excluding 'from ... import ...' style)
// which import multiple modules within a single line.
from Import singleLineMultiImport
where 
    // Exclude 'from ... import ...' style imports
    not singleLineMultiImport.isFromImport()
    // Check if the statement imports multiple modules
    and count(singleLineMultiImport.getAName()) > 1
select singleLineMultiImport, "Multiple imports on one line."