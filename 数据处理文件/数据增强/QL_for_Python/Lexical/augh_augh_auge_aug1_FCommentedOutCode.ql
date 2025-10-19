/**
 * @name File-level commented code line statistics
 * @description Analyzes and reports the count of lines containing commented-out code across Python files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files */

// Import necessary CodeQL libraries for Python analysis and commented code identification
import python
import Lexical.CommentedOutCode

// Define the main query variables representing Python files and their commented code metrics
from File pyFile, int commentedCodeCount

// Calculate the total number of commented-out code lines for each Python file,
// filtering out potential documentation or example code snippets
where 
    // Count all commented-out lines that belong to the current Python file
    commentedCodeCount = count(CommentedOutCodeLine commentedOutLine | 
        // Ensure the commented line is from the current file being analyzed
        commentedOutLine.getLocation().getFile() = pyFile and
        // Exclude lines that are likely to be example code or documentation
        not commentedOutLine.maybeExampleCode()
    )

// Generate the final results showing file paths and their corresponding commented code counts,
// sorted in descending order to highlight files with the highest amount of commented code
select pyFile, commentedCodeCount order by commentedCodeCount desc