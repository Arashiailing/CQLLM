/**
 * @name File Classification
 * @description Analyzes and categorizes source files in a codebase by
 *              identifying them as either auto-generated code or test files
 *              using specific classification criteria.
 * @kind file-classifier
 * @id py/file-classifier */

// Import necessary modules for Python code analysis
import python
// Import the GeneratedCode filter for detection of auto-generated files
import semmle.python.filters.GeneratedCode
// Import the Tests filter for identification of test-related files
import semmle.python.filters.Tests

// Define a predicate that assigns classification tags to files based on their characteristics
predicate classify(File targetFile, string typeTag) {
  // Condition 1: File is identified as generated code
  (targetFile instanceof GeneratedFile and typeTag = "generated")
  // Condition 2: File is part of test code
  or
  (exists(TestScope testContext | testContext.getLocation().getFile() = targetFile) and typeTag = "test")
}

// Query to retrieve all files with their assigned classification tags
from File targetFile, string typeTag
where classify(targetFile, typeTag)
select targetFile, typeTag