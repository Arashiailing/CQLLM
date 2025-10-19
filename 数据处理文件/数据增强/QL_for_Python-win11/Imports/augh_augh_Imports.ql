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
 * This query identifies Python import statements that import multiple modules on a single line.
 * According to PEP 8 style guide, imports should typically be on separate lines for better readability.
 * Non-compliant example:
 *   import os, sys, math
 * Compliant example:
 *   import os
 *   import sys
 *   import math
 */

// Import the Python analysis library for code parsing and analysis capabilities
import python

/**
 * Determines if an import statement contains multiple modules on a single line.
 * 
 * @param importStmt - The import statement to be checked
 * @returns true if the import statement contains multiple modules and is not a from-import form
 */
predicate containsMultipleImports(Import importStmt) { 
    // Count the number of modules in the import statement; more than 1 indicates multiple imports on one line
    count(importStmt.getAName()) > 1 and 
    // Exclude from...import... statements, focusing only on import modA, modB cases
    not importStmt.isFromImport() 
}

// Find all import statements that violate PEP 8 by importing multiple modules on a single line
from Import problematicImport
where containsMultipleImports(problematicImport)
select problematicImport, "Multiple imports on one line. According to PEP 8, imports should usually be on separate lines."