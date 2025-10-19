/**
 * @name Source File Type Classifier
 * @description Categorizes source files by identifying auto-generated code
 *              and test files through pattern matching and path analysis.
 *              This classification helps in understanding codebase structure
 *              and allows focused security analysis by filtering file types.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import core Python analysis module
import python
// Import module for detecting auto-generated source files
import semmle.python.filters.GeneratedCode
// Import module for identifying test-related files and directories
import semmle.python.filters.Tests

// Main query that classifies files based on their characteristics and context
from File targetFile, string fileCategory
where 
  // Check if the file is auto-generated
  targetFile instanceof GeneratedFile and fileCategory = "generated"
  // Check if the file is within a test context
  or
  (
    exists(TestScope testLocation | 
      testLocation.getLocation().getFile() = targetFile
    ) 
    and fileCategory = "test"
  )
select targetFile, fileCategory