/**
 * @name Source File Type Classifier
 * @description Identifies and classifies source files by detecting auto-generated
 *              code and test files using pattern recognition and location analysis.
 *              This classification aids in code organization understanding and
 *              enables targeted filtering during security assessments.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import core Python analysis module
import python
// Import module for detecting auto-generated source files
import semmle.python.filters.GeneratedCode
// Import module for identifying test-related files and directories
import semmle.python.filters.Tests

// Main classification query that categorizes files by their type and purpose
from File sourceFile, string classificationType
where 
  // Condition 1: File is auto-generated
  sourceFile instanceof GeneratedFile and classificationType = "generated"
  // Condition 2: File is in test context
  or
  (
    exists(TestScope testContext | 
      testContext.getLocation().getFile() = sourceFile
    ) 
    and classificationType = "test"
  )
select sourceFile, classificationType