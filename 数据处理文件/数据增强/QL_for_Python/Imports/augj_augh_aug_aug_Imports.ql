/**
 * @name Multiple imports on one line
 * @description Identifies Python import statements that breach PEP 8's coding standard
 *              which recommends one import per line for better code readability and
 *              easier maintenance. This query specifically targets lines with multiple
 *              module imports, excluding 'from ... import ...' constructs.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

import python

// This query detects import statements that violate PEP 8's guideline of one import per line.
// It focuses on standard import statements (not 'from ... import ...') that import
// multiple modules in a single line, which can reduce code clarity and maintainability.
from Import violationImport
where 
    // Condition 1: The import statement contains multiple modules
    count(violationImport.getAName()) > 1
    // Condition 2: The import is not of the 'from ... import ...' style
    and not violationImport.isFromImport()
select violationImport, "Multiple imports on one line."