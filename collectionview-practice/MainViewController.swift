//
//  ViewController.swift
//  collectionview-practice
//
//  Created by jinsei_shima on 2019/06/18.
//  Copyright © 2019 jinsei_shima. All rights reserved.
//

import UIKit

// UICollectionViewCompositionalLayoutと
// UICollectionViewDiffableDataSourceの練習

// https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/compositional_layout_objects
// https://qiita.com/shiz/items/a6032543a237bf2e1d19

// このサンプルがすごい
// https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/using_collection_view_compositional_layouts_and_diffable_data_sources

final class MainViewController: UIViewController {

  struct CellModel : Hashable {

    let title: String

    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }

  }

  enum Section: CaseIterable {
    case header
    case detail
  }

  class Cell : UICollectionViewCell {

  }

  class HeaderView: UICollectionReusableView {

  }

  private let dataSource: UICollectionViewDiffableDataSource<Section, CellModel>

  private let collectionView: UICollectionView =  createCollectionView()

  private static func createCollectionView() -> UICollectionView {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
    collectionView.register(HeaderView.self, forSupplementaryViewOfKind: String(describing: HeaderView.self), withReuseIdentifier: String(describing: HeaderView.self))
    return collectionView
  }

  private static func createLayout() -> UICollectionViewLayout {

    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.2),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalWidth(0.2)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )

    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40)),
      elementKind: String(describing: HeaderView.self),
      alignment: .bottom
    )

    let section = NSCollectionLayoutSection(group: group)
    section.boundarySupplementaryItems = [sectionHeader]
    section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)

    return UICollectionViewCompositionalLayout(section: section)
  }

  init() {

    dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, cellModel) -> UICollectionViewCell? in

      let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as? Cell
      cell?.backgroundColor = .tertiarySystemBackground
      return cell
    })

    dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

      guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: String(describing: HeaderView.self),
        for: indexPath) as? HeaderView else { fatalError("Cannot create new supplementary") }
      supplementaryView.backgroundColor = .separator
      return supplementaryView
    }

    super.init(nibName: nil, bundle: nil)

  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    navigationController?.navigationBar.largeContentImage = UIImage().withTintColor(.black, renderingMode: .alwaysTemplate)
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true
    title = "Title"

    let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
    navigationItem.setRightBarButton(addButton, animated: false)

    collectionView.backgroundColor = .secondarySystemBackground
    collectionView.frame = view.bounds
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.alwaysBounceVertical = true
    collectionView.delegate = self

    view.addSubview(collectionView)

    var snapshot = dataSource.snapshot()
    snapshot.appendSections(Section.allCases)
    snapshot.appendItems([CellModel(title: "Header Item")], toSection: .header)
    dataSource.apply(snapshot)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func addItem() {
    var snapshot = dataSource.snapshot()
    snapshot.appendItems([CellModel(title: "Detail Item")], toSection: .detail)
    dataSource.apply(snapshot)
  }
}

extension MainViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = dataSource.collectionView(collectionView, cellForItemAt: indexPath)
    let item = dataSource.itemIdentifier(for: indexPath)
    print("fuga:", cell)
    print("hoge:", item)
  }
}
