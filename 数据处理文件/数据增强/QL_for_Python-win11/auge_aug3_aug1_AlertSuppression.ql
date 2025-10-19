/**
 * @name Alert suppression analysis
 * @description Detects and examines alert suppressions within Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression handling utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing functionality
private import semmle.python.Comment as PythonComment

// Represents an individual Python comment line
class SingleLineComment instanceof PythonComment::Comment {
  // Determine if comment has detailed location information
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Validate that location coordinates match parent class data
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginCol, endLine, endCol)
  }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Obtain string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node equipped with location tracking
class AstNode instanceof PythonComment::AstNode {
  // Determine if node has detailed location information
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Validate that location coordinates match parent class data
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginCol, endLine, endCol)
  }

  // Obtain string representation of the AST node
  string toString() { result = super.toString() }
}

// Establish suppression associations between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression marker. Respected by both pylint and pyflakes, 
 * and therefore should be supported by lgtm as well.
 */
// Represents a suppression comment using noqa notation
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor validates comment conforms to noqa pattern
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional trailing content
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the scope of code affected by this suppression
  override predicate covers(
    string sourcePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Extract comment location and verify it begins at column 1
    this.hasLocationInfo(sourcePath, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}