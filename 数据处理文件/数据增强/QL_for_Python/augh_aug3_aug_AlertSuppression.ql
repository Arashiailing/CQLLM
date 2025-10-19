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

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Check if comment matches specified location coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Retrieve comment text content
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Represents AST nodes with location tracking
class AstNode instanceof P::AstNode {
  // Check if node matches specified location coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Return string representation of the node
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
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract location details from comment
    exists(int cStartLine, int cEndLine, int cEndCol |
      this.hasLocationInfo(file, cStartLine, _, cEndLine, cEndCol) and
      // Enforce line-start position and match boundaries
      startLine = cStartLine and
      endLine = cEndLine and
      startCol = 1 and
      endCol = cEndCol
    )
  }
}