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
 * This query identifies import statements that import multiple modules in a single line,
 * which violates PEP 8 style guidelines recommending one import per line.
 * Example: 'import modA, modB' should be split into separate lines.
 */

// Import Python analysis library for parsing and analyzing Python code
import python

// Define a predicate to check if an import statement contains multiple modules
predicate isMultilineImport(Import importStmt) {
    // Count the number of imported module names and verify it exceeds one
    exists(int nameCount | nameCount = count(importStmt.getAName()) and nameCount > 1) and
    // Exclude "from X import Y" style imports, as they are different case
    not importStmt.isFromImport()
}

// Find all import statements that satisfy the multiline import condition
from Import multilinedImport
where isMultilineImport(multilinedImport)
select multilinedImport, "Multiple imports on one line."