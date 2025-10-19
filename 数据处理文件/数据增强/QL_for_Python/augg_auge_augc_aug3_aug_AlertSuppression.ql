/**
 * @name Alert suppression
 * @description Identifies and processes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing capabilities
private import semmle.python.Comment as P

// Enhanced AST node wrapper with precise location tracking
class AstNode instanceof P::AstNode {
  // Verify node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFile, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    super.getLocation().hasLocationInfo(sourceFile, lineStart, colStart, lineEnd, colEnd)
  }

  // Generate textual representation of the AST node
  string toString() { result = super.toString() }
}

// Enhanced single-line comment representation with location details
class SingleLineComment instanceof P::Comment {
  // Validate comment matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFile, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    super.getLocation().hasLocationInfo(sourceFile, lineStart, colStart, lineEnd, colEnd)
  }

  // Retrieve the actual comment text content
  string getText() { result = super.getContents() }

  // Generate textual representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships using AlertSuppression framework
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents noqa suppression comments compatible with pylint and pyflakes.
 * These comments are recognized by LGTM analysis for alert suppression.
 */
// Models noqa-style suppression comments in Python code
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Identify noqa comment patterns during initialization
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return standardized suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string sourceFile, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Extract and validate comment location boundaries
    exists(int cmtStartLine, int cmtEndLine, int cmtEndCol |
      // Retrieve comment's precise location details
      this.hasLocationInfo(sourceFile, cmtStartLine, _, cmtEndLine, cmtEndCol) and
      // Map coverage to comment's line boundaries
      lineStart = cmtStartLine and
      lineEnd = cmtEndLine and
      colStart = 1 and
      colEnd = cmtEndCol
    )
  }
}