/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as P

// Represents a Python AST node with location tracking
class AstNode instanceof P::AstNode {
  // Retrieve location details for the AST node
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Provide string representation of the node
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment
class SingleLineComment instanceof P::Comment {
  // Retrieve location details for the comment
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Get the text content of the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Get the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range covered by this suppression
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Ensure comment starts at column 1 and get its location
    beginCol = 1 and
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol)
  }
}