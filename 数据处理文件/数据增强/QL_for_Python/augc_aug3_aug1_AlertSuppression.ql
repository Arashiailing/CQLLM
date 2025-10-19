/**
 * @name Alert suppression analysis
 * @description Detects and evaluates alert suppression mechanisms in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for handling suppressions
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as PythonComment

// Represents a Python comment that spans a single line
class SingleLineComment instanceof PythonComment::Comment {
  // Determine if the comment has specific location details
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Validate that the location matches parent class location information
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Obtain a string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node equipped with location tracking capabilities
class AstNode instanceof PythonComment::AstNode {
  // Verify if the node has specific positional information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Confirm that the location aligns with parent class location data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Generate a string representation of the AST node
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A suppression comment using the noqa directive. This directive is recognized by
 * both pylint and pyflakes linters, and should therefore be supported by lgtm as well.
 */
// Represents a suppression comment that follows the noqa convention
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that verifies the comment matches the noqa pattern
  NoqaSuppressionComment() {
    // Identify comments containing a case-insensitive noqa directive with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier associated with this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code scope covered by this suppression directive
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Extract comment location and ensure it begins at the first column
    this.hasLocationInfo(sourceFilePath, beginLine, _, endLine, endColumn) and
    beginColumn = 1
  }
}