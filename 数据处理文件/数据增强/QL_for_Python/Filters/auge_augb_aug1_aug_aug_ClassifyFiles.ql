/**
 * @name Python Source File Classification
 * @description Identifies and classifies Python source files by detecting
 *              auto-generated code and test files using pattern recognition
 *              and directory structure analysis. This classification enables
 *              focused security assessments by allowing analysts to filter
 *              specific file categories during codebase reviews.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import core Python language analysis module
import python
// Import generated code detection utilities
import semmle.python.filters.GeneratedCode
// Import test file identification utilities
import semmle.python.filters.Tests

// Main query logic for file classification based on generation source and purpose
from File sourceFile, string classificationType
where 
  // Classification rule 1: Identify auto-generated files
  (sourceFile instanceof GeneratedFile and classificationType = "generated")
  // Classification rule 2: Identify test-related files
  or
  (exists(TestScope testContext | 
          testContext.getLocation().getFile() = sourceFile) 
   and classificationType = "test")
select sourceFile, classificationType