/**
 * @name Alert suppression analysis
 * @description Identifies and evaluates alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing capabilities
private import semmle.python.Comment as PythonComment

// Represents a single-line Python comment with detailed location metadata
class SingleLineComment instanceof PythonComment::Comment {
  // Check if the comment contains specific location details
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int finishLine, int finishCol
  ) {
    // Validate that location information matches parent class data
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, finishLine, finishCol)
  }

  // Extract the textual content of the comment
  string getText() { result = super.getContents() }

  // Generate a string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node with comprehensive location tracking
class AstNode instanceof PythonComment::AstNode {
  // Verify if the node contains specific position details
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int finishLine, int finishCol
  ) {
    // Ensure location data aligns with parent class information
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, finishLine, finishCol)
  }

  // Create a string representation of the AST node
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * Suppression comment using the noqa directive. This directive is recognized by
 * major Python linters including pylint and pyflakes, and is therefore supported by lgtm.
 */
// Represents a suppression comment following the noqa convention
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that validates the comment matches the noqa pattern
  NoqaSuppressionComment() {
    // Identify comments containing a case-insensitive noqa directive with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression mechanism
  override string getAnnotation() { result = "lgtm" }

  // Determine the code scope influenced by this suppression directive
  override predicate covers(
    string filePath, int startLine, int startCol, int finishLine, int finishCol
  ) {
    // Extract comment location and confirm it starts at the first column
    this.hasLocationInfo(filePath, startLine, _, finishLine, finishCol) and
    startCol = 1
  }
}