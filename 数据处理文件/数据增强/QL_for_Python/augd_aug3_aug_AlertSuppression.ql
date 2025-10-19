/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking
class AstNode instanceof P::AstNode {
  // Check if node matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLn, int startCol, int endLn, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLn, startCol, endLn, endCol)
  }

  // Return string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Check if comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLn, int startCol, int endLn, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLn, startCol, endLn, endCol)
  }

  // Retrieve comment text content
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents noqa-style suppression comments
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLn, int startCol, int endLn, int endCol
  ) {
    exists(int cStartLn, int cEndLn, int cEndCol |
      this.hasLocationInfo(filePath, cStartLn, _, cEndLn, cEndCol) and
      // Enforce line-start position and match boundaries
      startLn = cStartLn and
      endLn = cEndLn and
      startCol = 1 and
      endCol = cEndCol
    )
  }
}