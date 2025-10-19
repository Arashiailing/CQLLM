/**
 * @name Multiple imports on one line
 * @description Placing multiple import statements on a single line reduces code readability;
 *              PEP8 recommends that imports should typically be on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

/*
 * This query identifies import statements with the following pattern:
 * import modA, modB
 * (According to PEP 8, each import should be on its own line)
 */

// Import the Python module for parsing and analyzing Python code
import python

// Define a predicate to detect multi-module import statements
predicate multiple_import(Import importStmt) { 
    // Check if the import statement contains more than one module name
    count(importStmt.getAName()) > 1 and 
    // Ensure the import is not a "from ... import ..." style statement
    not importStmt.isFromImport() 
}

// Query all import statements that match the multiple_import condition
from Import importDeclaration
where multiple_import(importDeclaration)
select importDeclaration, "Multiple imports on one line."