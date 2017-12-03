//
//  Copyright © 2017 test. All rights reserved.
//

import UIKit

class RepositoryListRouter {

    private var interactor: RepositoryListInteractor!
    private var presenter: RepositoryListPresenter!
    private var viewController: RepositoryListViewController!

    func displayInWindow(_ window: UIWindow) {
        self.interactor = RepositoryListInteractor()
        self.presenter = RepositoryListPresenter()
        self.viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepositoryList") as! RepositoryListViewController

        self.interactor.output = self.presenter

        self.presenter.interactor = self.interactor
        self.presenter.view = self.viewController

        self.viewController.output = self.presenter

        window.rootViewController = self.viewController
    }
}
