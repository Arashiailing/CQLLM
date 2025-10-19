/**
 * @name Alert suppression
 * @description Offers comprehensive insights into alert suppression mechanisms within Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for analyzing code comments
private import semmle.python.Comment as PyComment

// Represents AST nodes with enhanced location tracking capabilities
class EnhancedAstNode instanceof PyComment::AstNode {
  // Check whether the node aligns with given location coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Produce textual representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with precise location tracking
class EnhancedSingleLineComment instanceof PyComment::Comment {
  // Ascertain whether the comment corresponds to provided location coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Retrieve the textual content contained within the comment
  string getText() { result = super.getContents() }

  // Deliver textual representation of the comment
  string toString() { result = super.toString() }
}

// Implement suppression relationship creation utilizing the AlertSuppUtil template
import AlertSuppUtil::Make<EnhancedAstNode, EnhancedSingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Denotes suppression comments adhering to the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof EnhancedSingleLineComment {
  // Initializer that recognizes noqa comment patterns
  NoqaSuppressionComment() {
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Deliver the identifier for the suppression annotation
  override string getAnnotation() { result = "lgtm" }

  // Establish the coverage scope for this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Validate comment location correspondence and mandate line-start positioning
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}