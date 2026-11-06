import UIKit

final class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private let cellIdentifier = "FavoriteCell"
    private let items = FavoritesLibrary.items

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath
            ) as? FavoriteCell
        else {
            fatalError(
                "Prototype cell \"\(cellIdentifier)\" must have its class set to FavoriteCell"
            )
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }
}
