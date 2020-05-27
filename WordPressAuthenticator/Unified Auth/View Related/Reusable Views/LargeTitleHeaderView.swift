import UIKit


/// LargeTitleHeaderView: the header view for the entire table.
///
final public class LargeTitleHeaderView: UIView {

    @IBOutlet public weak var titleLabel: UILabel!

    public override class func awakeFromNib() {
        super.awakeFromNib()
    }

    class func makeFromNib() -> LargeTitleHeaderView {
        return Bundle.main.loadNibNamed("LargeTitleHeaderView", owner: self, options: nil)?.first as! LargeTitleHeaderView
    }
}
