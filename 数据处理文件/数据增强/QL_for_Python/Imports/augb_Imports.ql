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

/*
 * This query detects import statements violating PEP8 by importing
 * multiple modules in a single line (e.g., "import modA, modB").
 * Such imports should be split into separate lines for better readability.
 */

// Import Python analysis library
import python

// Predicate identifying non-PEP8 compliant multi-module imports
predicate isMultipleImportsOnSingleLine(Import importStmt) {
    // Check if the import statement contains multiple module names
    exists(int nameCount | nameCount = count(importStmt.getAName()) | nameCount > 1) and
    // Exclude "from ... import ..." statements which have different syntax
    not importStmt.isFromImport()
}

// Query: Find all import statements violating single-line multi-module rule
from Import importStmt
where isMultipleImportsOnSingleLine(importStmt)
select importStmt, "Multiple imports on one line."