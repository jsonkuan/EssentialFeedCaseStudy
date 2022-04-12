import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshController?

    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    convenience init(refreshController: FeedRefreshController) {
        self.init()

        self.refreshController = refreshController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self

        refreshController?.refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellControllerForRow(at: indexPath).view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoads(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllerForRow(at: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoads)
    }

    private func cellControllerForRow(at indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }

    private func cancelCellControllerLoads(forRowAt index: IndexPath) {
        cellControllerForRow(at: index).cancelLoad()
    }
}
