/**
 * @name Alert suppression
 * @description Provides comprehensive analysis of alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for suppression logic handling
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as PyComment

// Represents AST nodes with enhanced location tracking
class AstNode instanceof PyComment::AstNode {
  // Verify if node matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate textual representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PyComment::Comment {
  // Determine if comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract textual content from the comment
  string getText() { result = super.getContents() }

  // Generate textual representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationship using AlertSuppUtil template
import AlertSuppUtil::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents suppression comments following the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that identifies noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define coverage scope for this suppression annotation
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Validate comment location and enforce line-start positioning
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}