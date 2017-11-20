//
//  Page.swift
//  SwiftBoard
//
//  Created by Andrew Finke on 11/16/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit

enum PageItemType {
    case today, spotlight, boardItems([BoardItem])
}

protocol PageItem {
    var type: PageItemType { get }
}


class PagesCollectionViewLayout: UICollectionViewFlowLayout {

    // MARK: - Initalization

    override init() {
        super.init()

        let spacing: CGFloat = 0.0
        minimumLineSpacing = spacing
        minimumInteritemSpacing = spacing

        sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        scrollDirection = .horizontal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PagesCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {

    let layout = PagesCollectionViewLayout()

    // MARK: - Initalization

    init() {
        super.init(frame: .zero, collectionViewLayout: layout)

        self.isPagingEnabled = true
        self.register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.reuseIdentifier)

        // BAD ANDREW! BAD! YOU SHOULD KNOW BETTER. YOU'RE BETTER THAN THIS.
        self.delegate = self
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - layout.sectionInset.left * 2
        let height = collectionView.frame.height - layout.sectionInset.top * 2

        guard width >= 0 && height >= 0 else {
            return CGSize.zero
        }
        return CGSize(width: width, height: height)
    }
}

class PageCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "reuseIdentifier"

    private let itemsCollectionView = BoardItemPageCollectionView()
    private let itemsDataSource = BoardItemPageCollectionViewDataSource()

    var pageType: PageItemType? {
        didSet {
            if case .boardItems(let items)? = pageType {
                itemsDataSource.add(items)
                itemsCollectionView.isHidden = false
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        itemsCollectionView.dataSource = itemsDataSource
        itemsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemsCollectionView)

        let constraints = [
            itemsCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            itemsCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            itemsCollectionView.topAnchor.constraint(equalTo: topAnchor),
            itemsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PagesCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    // MARK: - Properties

    var pageTypes: [PageItemType] = []

    func add(_ item: PageItemType) {
        pageTypes.append(item)
    }

    func add(_ items: [PageItemType]) {
        items.forEach({ add($0) })
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.reuseIdentifier, for: indexPath) as? PageCollectionViewCell else {
            fatalError("Failed to dequeue cell")
        }
        cell.pageType = pageTypes[indexPath.row]
        return cell
    }

}


