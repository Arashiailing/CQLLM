/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for analyzing code comments
private import semmle.python.Comment as PyComment

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PyComment::Comment {
  // Validate comment location matches specified coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Extract the textual content from the comment
  string getText() { result = super.getContents() }

  // Generate textual representation of the comment
  string toString() { result = super.toString() }
}

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof PyComment::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Generate textual representation of the AST node
  string toString() { result = super.toString() }
}

// Implement suppression relationship creation using AlertSuppUtil template
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

  // Return the identifier for the suppression annotation
  override string getAnnotation() { result = "lgtm" }

  // Define the coverage scope for this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Verify comment location matches and enforce line-start positioning
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}