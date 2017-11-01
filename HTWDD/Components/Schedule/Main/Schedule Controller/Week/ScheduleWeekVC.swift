//
//  ScheduleWeekVC.swift
//  HTWDD
//
//  Created by Fabian Ehlert on 30.10.17.
//  Copyright © 2017 HTW Dresden. All rights reserved.
//

import UIKit
import RxSwift

final class ScheduleWeekVC: ScheduleBaseVC {

	// MARK: - Init

	init(configuration: ScheduleDataSource.Configuration) {
        let layout = ScheduleWeekLayout()
        super.init(configuration: configuration, layout: layout, startHour: 6.5)
        layout.dataSource = self
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func initialSetup() {
        super.initialSetup()
        self.collectionView.isDirectionalLockEnabled = true
        
        self.dataSource.register(type: LectureCollectionViewCell.self)
	}

}

// MARK: - ScheduleWeekLayoutDataSource
extension ScheduleWeekVC: ScheduleWeekLayoutDataSource {
	var widthPerDay: CGFloat {
		let numberOfDays = 7
		return self.view.bounds.width / CGFloat(numberOfDays)
	}

	var height: CGFloat {
		let navbarHeight = self.navigationController?.navigationBar.bottom ?? 0
		return self.collectionView.bounds.height - navbarHeight
	}

	var endHour: CGFloat {
		return 21.3
	}

	func dateComponentsForItem(at indexPath: IndexPath) -> (begin: DateComponents, end: DateComponents)? {
		guard let item = self.dataSource.lecture(at: indexPath) else {
			return nil
		}
		return (item.begin, item.end)
	}
}
