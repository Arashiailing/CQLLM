/**
 * @name Analysis of Alert Suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression handling utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing functionality
private import semmle.python.Comment as PythonComment

// Represents a Python AST node with location information
class AstNode instanceof PythonComment::AstNode {
  // Obtain string representation of the AST node
  string toString() { result = super.toString() }

  // Determine if node has detailed location information
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Validate that location coordinates match parent class data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }
}

// Denotes a single-line comment in Python source code
class SingleLineComment instanceof PythonComment::Comment {
  // Obtain string representation of the comment
  string toString() { result = super.toString() }

  // Determine if comment has detailed location information
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Validate that location coordinates match parent class data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }
}

// Establish suppression associations between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression marker. Respected by both pylint and pyflakes, 
 * and therefore should be supported by lgtm as well.
 */
// Denotes a suppression comment that uses the noqa notation
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
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Extract comment location and verify it begins at column 1
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}