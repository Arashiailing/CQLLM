/**
 * @name Automated File Categorization
 * @description Identifies and categorizes files within a Python project by
 *              detecting auto-generated code and test files using pattern
 *              recognition and directory hierarchy analysis.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import necessary modules for Python code analysis and file classification
import python
// Import utility for recognizing automatically generated source files
import semmle.python.filters.GeneratedCode
// Import utility for detecting test-related files and directories
import semmle.python.filters.Tests

// Main query that directly incorporates file classification logic
// to identify auto-generated and test-related files
from File targetFile, string classificationType
where (
  // Check if the file is auto-generated
  (targetFile instanceof GeneratedFile and classificationType = "generated")
  // Check if the file is part of test code
  or
  (exists(TestScope testEnvironment | testEnvironment.getLocation().getFile() = targetFile) and classificationType = "test")
)
select targetFile, classificationType