//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Andrew Finke on 11/14/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let apps = [
        App(name: "Messages", icon: createIcon(for: UIColor.green), isRemovable: true, actions: nil, badgeNumber: 4),
        App(name: "Calendar", icon: createIcon(for: UIColor.white), isRemovable: true, actions: nil, badgeNumber: 0),
        App(name: "Safari", icon: createIcon(for: UIColor.purple), isRemovable: true, actions: nil, badgeNumber: 0),
        App(name: "Phone", icon: createIcon(for: UIColor.orange), isRemovable: true, actions: nil, badgeNumber: 0),
        App(name: "Clock", icon: createIcon(for: UIColor.black), isRemovable: true, actions: nil, badgeNumber: 0)
    ]


    let pagesCollectionView = PagesCollectionView()
    let dataSource = PagesCollectionViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        let boardItems = apps.map({ AppItem(app: $0) })
        let firstPage = PageItemType.boardItems(boardItems)
        let secondPage = PageItemType.boardItems(boardItems)

        dataSource.add([firstPage, secondPage])

    //    pagesCollectionView.delegate = self
        pagesCollectionView.dataSource = dataSource

        pagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pagesCollectionView)

        let constraints = [
            pagesCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pagesCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            pagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ]
        NSLayoutConstraint.activate(constraints)

        view.backgroundColor = UIColor.lightGray

//        let boardItems = apps.map({ AppItem(app: $0) })
//        dataSource.add(boardItems)
//
//        let singlePageCollectionView = BoardItemPageCollectionView()
//        singlePageCollectionView.dataSource = dataSource
//
//        singlePageCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(singlePageCollectionView)
//
//        let constraints = [
//            singlePageCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            singlePageCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            singlePageCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            singlePageCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//        ]
//        NSLayoutConstraint.activate(constraints)
//
//        singlePageCollectionView.backgroundColor = UIColor.lightGray

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = pagesCollectionView.contentOffset.x / pagesCollectionView.frame.width
            print(currentPage)

//
//        - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//        {
//            CGFloat pageWidth = collectionView.frame.size.width;
//            float currentPage = collectionView.contentOffset.x / pageWidth;
//
//            if (0.0f != fmodf(currentPage, 1.0f))
//            {
//                pageControl.currentPage = currentPage + 1;
//            }
//            else
//            {
//                pageControl.currentPage = currentPage;
//            }
//
//            NSLog(@"Page Number : %ld", (long)pageControl.currentPage);
//        }
    }
}

