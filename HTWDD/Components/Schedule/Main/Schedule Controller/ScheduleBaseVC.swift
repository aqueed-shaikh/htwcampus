//
//  ScheduleBaseVC.swift
//  HTWDD
//
//  Created by Benjamin Herzog on 31.10.17.
//  Copyright © 2017 HTW Dresden. All rights reserved.
//

import UIKit

class ScheduleBaseVC: CollectionViewController {

    let dataSource: ScheduleDataSource

    private var lastSelectedIndexPath: IndexPath?

    let startHour: CGFloat

    var auth: ScheduleService.Auth? {
        get { return nil }
        set { self.dataSource.auth = newValue }
    }

    init(configuration: ScheduleDataSource.Configuration, layout: UICollectionViewLayout, startHour: CGFloat) {
        self.dataSource = ScheduleDataSource(configuration: configuration)
        self.startHour = startHour
        super.init(layout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initialSetup() {
        super.initialSetup()

        self.collectionView.backgroundColor = UIColor.htw.veryLightGrey

        // DataSource
        self.dataSource.collectionView = self.collectionView
        self.dataSource.registerSupplementary(LectureHeaderView.self, kind: .header) { [weak self] view, indexPath in
            guard let `self` = self else { return }
            let info = self.dataSource.dayInformation(indexPath: indexPath)
            view.title = self.headerText(day: info.day, date: info.date, weekdayLoca: info.loca)
        }
        self.dataSource.registerSupplementary(LectureTimeView.self, kind: .description) { [weak self] time, indexPath in
            guard let `self` = self else {
                return
            }
            let hour = Int(self.startHour) - 1 + indexPath.row
            time.timeString = String(hour)
        }
    }

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let todayButton = UIBarButtonItem(title: Loca.Schedule.today, style: .plain, target: self, action: #selector(jumpToToday))
        self.navigationItem.rightBarButtonItem = todayButton

        self.dataSource.load()

		DispatchQueue.main.async {
			self.register3DTouch()
		}
    }

    // MARK: - Private

    private func register3DTouch() {
        guard self.traitCollection.forceTouchCapability == .available else {
            return
        }
        self.registerForPreviewing(with: self, sourceView: self.collectionView)
    }

    fileprivate func presentDetail(_ controller: UIViewController, animated: Bool) {
        self.navigationController?.pushViewController(controller, animated: animated)
    }

    @objc
    func jumpToToday() {
        let left = CGPoint(x: -self.collectionView.contentInset.left, y: self.collectionView.contentOffset.y)
        self.collectionView.setContentOffset(left, animated: true)
    }

    func headerText(day: Day, date: Date, weekdayLoca: String) -> String {
        return weekdayLoca
    }

}

// MARK: - CollectionViewDelegate
extension ScheduleBaseVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.lecture(at: indexPath) else {
            Log.error("Expected to get a lecture for indexPath \(indexPath), but got nothing from dataSource..")
            return
        }
        self.lastSelectedIndexPath = indexPath
        let detail = ScheduleDetailVC(lecture: item)
        self.presentDetail(detail, animated: true)
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension ScheduleBaseVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let indexPath = self.collectionView.indexPathForItem(at: location),
            let item = self.dataSource.lecture(at: indexPath)
            else {
                return nil
        }

        if let cell = self.collectionView.cellForItem(at: indexPath) {
            previewingContext.sourceRect = cell.frame
        }

        self.lastSelectedIndexPath = indexPath
        return ScheduleDetailVC(lecture: item)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.presentDetail(viewControllerToCommit, animated: false)
    }
}

// MARK: - AnimatedViewControllerTransitionDataSource
extension ScheduleBaseVC: AnimatedViewControllerTransitionDataSource {
    func viewForTransition(_ transition: AnimatedViewControllerTransition) -> UIView? {
        return self.lastSelectedIndexPath.flatMap(self.collectionView.cellForItem(at:))
    }
}
