//
//  App.swift
//  SwiftBoard
//
//  Created by Andrew Finke on 11/14/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit


func createIcon(for color: UIColor) -> UIImage {
    let size = CGSize(width: 200, height: 200)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
        UIColor.darkGray.setStroke()
        context.stroke(renderer.format.bounds)
        color.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
}

let PAGEMAXITEMS = 20
let PAGEMAXROWITEMS = 4

let FOLDERPAGEMAXITEMS = 9
let FOLDERPAGEMAXROWITEMS = 3



typealias Page = [BoardItem]

struct App {
    let name: String
    let icon: UIImage
    let isRemovable: Bool
    let actions: [ForcePressAction]?
    let badgeNumber: Int
}

// MARK: - Model

enum BoardItemType {
    case app, folder, webclip
}

protocol BoardItem {
    var type: BoardItemType { get }
    var name: String? { get }
    var image: UIImage { get }
    var badgeNumber: Int? { get }


    var isRemovable: Bool  { get }
    var actions: [ForcePressAction]? { get }
}

struct ForcePressAction {
    let title: String
    let image: UIImage?
    //let action: (() -> Void)
}

struct AppItem: BoardItem {
    let type: BoardItemType = .app

    let name: String?
    var image: UIImage
    var isRemovable: Bool
    var actions: [ForcePressAction]?


    var badgeNumber: Int?

    init(app: App) {
        self.name = app.name
        self.image = app.icon
        self.isRemovable = app.isRemovable
        self.badgeNumber = app.badgeNumber
        self.actions = (app.actions ?? []) + [ForcePressAction(title: "Share", image: nil)]
    }

}

struct FolderItem: BoardItem {
    let type: BoardItemType = .folder

    let name: String?

    var image: UIImage
    var isRemovable: Bool = false
    var actions: [ForcePressAction]?

    var badgeNumber: Int?

    init(name: String, items: [Page]) {
        self.name = name
        self.image = UIImage() // createPreview(for: items)
        self.badgeNumber = items.joined().flatMap({ item in
            return item.badgeNumber ?? 0
        }).reduce(0, +)

        for page in items where page.count > FOLDERPAGEMAXITEMS {
            fatalError("Too many items in folder")
        }
    }

}

struct DockItem {
    let items: [BoardItem]
}

class BoardItemView: UIView {

    // MARK: - Interface

    private let iconView = UIImageView()

    private let badgeLabel = UILabel()
    private let deleteLabel = UILabel()

    private let titleLabel = UILabel()

    var item: BoardItem? {
        didSet {
            iconView.image = item?.image
            titleLabel.text = item?.name

            if let number = item?.badgeNumber, number > 0 {
                badgeLabel.text = number.description
                badgeLabel.isHidden = false
            } else {
                badgeLabel.isHidden = true
            }
        }
    }

    // MARK: - Initalization

    init() {
        super.init(frame: .zero)

        iconView.layer.cornerRadius = 7.5
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(titleLabel)

        let badgeSize: CGFloat = 25.0;

        badgeLabel.textAlignment = .center
        badgeLabel.textColor = UIColor.white
        badgeLabel.backgroundColor = UIColor.red
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        badgeLabel.layer.cornerRadius = badgeSize / 2
        badgeLabel.clipsToBounds = true
        addSubview(badgeLabel)

        let constraints = [
            iconView.leftAnchor.constraint(equalTo: leftAnchor),
            iconView.rightAnchor.constraint(equalTo: rightAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            badgeLabel.widthAnchor.constraint(equalToConstant: badgeSize),
            badgeLabel.heightAnchor.constraint(equalToConstant: badgeSize),
            badgeLabel.centerXAnchor.constraint(equalTo: iconView.rightAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: iconView.topAnchor),
        ]
        NSLayoutConstraint.activate(constraints)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        addGestureRecognizer(longPressGesture)

        NotificationCenter.default.addObserver(forName: NSNotification.Name("StartDeleteAnimation"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.startDeleteAnimation()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Delete Animation

    @objc
    func didLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name("StartDeleteAnimation"), object: nil)
    }

    func startDeleteAnimation() {
        shakeLeft()
    }

    private func shakeLeft() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 48)
        }, completion: { _ in
            self.shakeRight()
        })
    }

    private func shakeRight() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 48)
        }, completion: { _ in
            self.shakeLeft()
        })
    }
}

class BoardItemPageCollectionViewLayout: UICollectionViewFlowLayout {

    // MARK: - Initalization

    override init() {
        super.init()

        let spacing: CGFloat = 24.0
        minimumLineSpacing = spacing
        minimumInteritemSpacing = spacing

        sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardItemPageCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {

    let layout = BoardItemPageCollectionViewLayout()

    // MARK: - Initalization

    init() {
        super.init(frame: .zero, collectionViewLayout: layout)
        self.register(BoardItemCollectionViewCell.self, forCellWithReuseIdentifier: BoardItemCollectionViewCell.reuseIdentifier)

        // BAD ANDREW! BAD! YOU SHOULD KNOW BETTER. YOU'RE BETTER THAN THIS.
        self.delegate = self
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.frame.width - layout.sectionInset.left * 2 - layout.minimumInteritemSpacing * CGFloat(PAGEMAXROWITEMS)) / CGFloat(PAGEMAXROWITEMS)
        guard itemWidth >= 0 else {
            return CGSize.zero
        }
        return CGSize(width: itemWidth, height: itemWidth + 20.0)
    }
}

class BoardItemCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "reuseIdentifier"

    private let boardItemView = BoardItemView()
    var item: BoardItem? {
        didSet {
            boardItemView.item = item
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        boardItemView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(boardItemView)

        let constraints = [
            boardItemView.leftAnchor.constraint(equalTo: leftAnchor),
            boardItemView.rightAnchor.constraint(equalTo: rightAnchor),
            boardItemView.topAnchor.constraint(equalTo: topAnchor),
            boardItemView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardItemPageCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    // MARK: - Properties

    var items: Page = []

    func add(_ item: BoardItem) {
        items.append(item)
    }

    func add(_ items: Page) {
        items.forEach({ add($0) })
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardItemCollectionViewCell.reuseIdentifier, for: indexPath) as? BoardItemCollectionViewCell else {
            fatalError("Failed to dequeue cell")
        }
        cell.item = items[indexPath.row]
        return cell
    }

}





