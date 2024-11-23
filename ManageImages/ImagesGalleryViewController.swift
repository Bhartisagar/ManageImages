
import UIKit
import RealmSwift

class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var capturedImages: Results<CapturedImage>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchImagesFromRealm()
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        view.addSubview(collectionView)
    }

    func fetchImagesFromRealm() {
        let realm = try! Realm()
        capturedImages = realm.objects(CapturedImage.self)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let image = capturedImages[indexPath.row]
        
        let imageData = image.imageData
        let img = UIImage(data: imageData)
        cell.imageView.image = img
        var label = UILabel()
        label.text = image.imageName
        label.textAlignment = .center
        label.textColor = .red
        cell.imageView.addSubview(label)
        // Show upload progress and status
        cell.progressView.progress = image.uploadProgress
        cell.progressView.progressTintColor = .red
        cell.statusLabel.text = image.uploadStatus
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Image tapped at index \(indexPath.row)")  // Debugging
        
        let selectedImage = capturedImages[indexPath.row]
        let imageData = selectedImage.imageData
        let image = UIImage(data: imageData)
        
        // Open full-screen image view
        let imageDetailViewController = ImageDetailViewController()
        imageDetailViewController.image = image
        navigationController?.pushViewController(imageDetailViewController, animated: true)
    }
}

class ImageCell: UICollectionViewCell {
    var imageView: UIImageView!
    var progressView: UIProgressView!
    var statusLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: contentView.bounds)
        contentView.addSubview(imageView)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: contentView.bounds.height - 20, width: contentView.bounds.width, height: 10)
        contentView.addSubview(progressView)

        statusLabel = UILabel(frame: CGRect(x: 0, y: contentView.bounds.height - 40, width: contentView.bounds.width, height: 20))
        statusLabel.textAlignment = .center
        contentView.addSubview(statusLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ImageDetailViewController: UIViewController {
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let image = image else { return }

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)

        // Back Button
        let backButton = UIButton(frame: CGRect(x: 20, y: 40, width: 80, height: 40))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        backButton.layer.cornerRadius = 5
        backButton.addTarget(self, action: #selector(backToGallery), for: .touchUpInside)
        view.addSubview(backButton)
    }

    @objc private func backToGallery() {
        navigationController?.popViewController(animated: true)
    }
}
