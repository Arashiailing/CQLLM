/**
 * @name Source File Type Identification
 * @description Identifies and categorizes source files by detecting
 *              auto-generated code and test files using path patterns
 *              and contextual analysis. This classification enables
 *              targeted security assessments by differentiating between
 *              various file types in the codebase.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import core Python analysis module
import python
// Import module for detecting auto-generated source files
import semmle.python.filters.GeneratedCode
// Import module for identifying test-related files and directories
import semmle.python.filters.Tests

// Query that identifies and categorizes files based on their properties
from File sourceFile, string classification
where 
  // First condition: Identify auto-generated files
  sourceFile instanceof GeneratedFile and classification = "generated"
  // Second condition: Identify test files
  or
  (
    exists(TestScope testContext | 
      testContext.getLocation().getFile() = sourceFile
    ) 
    and classification = "test"
  )
select sourceFile, classification