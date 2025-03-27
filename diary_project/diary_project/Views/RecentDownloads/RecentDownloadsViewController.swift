import UIKit

class RecentDownloadsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var delegate: RecentDownloadsViewControllerDelegate?
    private var photos: [String] = []
    private var selectedPhoto: String?

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        photos = RecentDownloadsManager.shared.getDownloadedPhotos()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecentDownloadCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        navigationItem.title = "Recent Downloads"
    }

    @objc private func cancelPressed() {
        delegate?.recentDownloadsViewControllerDidCancel(self)
    }

    @objc private func donePressed() {
        if let selectedPhoto = selectedPhoto {
            delegate?.recentDownloadsViewController(self, didSelectPhoto: selectedPhoto)
        } else {
            delegate?.recentDownloadsViewControllerDidCancel(self)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RecentDownloadCell
        let photoPath = FileManager.default.temporaryDirectory.appendingPathComponent(photos[indexPath.item]).path
        cell.configure(with: photoPath, isSelected: photos[indexPath.item] == selectedPhoto)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhoto = photos[indexPath.item]
        collectionView.reloadData()
    }
}
