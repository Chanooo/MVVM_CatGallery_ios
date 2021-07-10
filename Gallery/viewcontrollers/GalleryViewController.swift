//
//  GalleryViewController.swift
//  Gallery
//

import UIKit

class GalleryViewController:
        UIViewController,
        UICollectionViewDelegate,
        UICollectionViewDataSource
{
    @IBOutlet var viewModel: GalleryViewModel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var isListMode = true // 1개로 보는지 여부 플래그
    private var isFetching = true // 서버에서 불러오는 중 플래그
    private var isRefresing = false
    
    private var errorLabel: UILabel = {
        let l = UILabel()
        l.text = "에러 발생"
        l.textAlignment = .center
        l.backgroundColor = .white
        l.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return l
    }()

    // ----- 코드 수정 제한 영역 시작 -----
    /// 다운로드한 이미지의 총 개수
    private var imageCount: Int = .zero {
        didSet {
            DispatchQueue.main.async {
                self.title = "\(self.imageCount)"
            }
        }
    }
    // ----- 코드 수정 제한 영역 끝 -----

    override func viewDidLoad() {
        super.viewDidLoad()

        // ----- 코드 수정 제한 영역 시작 -----
        assert(self.navigationController != nil, "self.navigationController must not be nil")
        self.title = "Gallery"
        setNavigationBarButtons()
        setNotificationObserver()
        // ----- 코드 수정 제한 영역 끝 -----
        
        
        initViews()
        bindViewModel()
        fetch()
       
    }
    
    
    private func initViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "ImageCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        
        // 에러화면
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            errorLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            errorLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            errorLabel.topAnchor.constraint(equalTo: view.topAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func bindViewModel() {
        viewModel.reloadClosure = { error, strErr in
            if let err = error {
                self.errorLabel.text = "\(err.rawValue) 에러발생"
                self.errorLabel.isHidden = false
            } else if let strErr = strErr {
                self.errorLabel.text = "에러발생\n\(strErr)"
                self.errorLabel.isHidden = false
            } else{
                self.errorLabel.isHidden = true
                self.collectionView.reloadData()
                self.isFetching = false
                
                if self.isRefresing {
                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    self.isRefresing = false
                }
            }
        }
    }
    
    
    private func fetch() {
        viewModel.fetchImages(start: viewModel.getDataCount()+1)
        isFetching = true
    }
    
    // MARK: - UICollectionViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let cell = collectionView.visibleCells.last as? GalleryCell {
//            print(cell.titleLabel.text)
//        }
        let curY = scrollView.contentOffset.y
        let screenHeight = UIScreen.main.bounds.height
        let height = scrollView.contentSize.height
//        print("\(screenHeight) / \(curY) / \(height)")
        
        if height < screenHeight + curY,
           !isFetching,
           viewModel.hasNextPage {
            fetch()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getDataCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isListMode {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as? GalleryCell,
               let data = viewModel.getData(index: indexPath)
            {
                cell.titleLabel.text = data.title
                if let image = ImageCachingManager.shared.cachingList[data.link] {
                    cell.imageView.image = image
                } else {
                    cell.imageView.setImage(from: data.link)
                }
                return cell
            }
        } else { // 3개씩 보여주는 경우
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell,
               let data = viewModel.getData(index: indexPath)
            {
                if let image = ImageCachingManager.shared.cachingList[data.link] {
                    cell.imageView.image = image
                } else {
                    cell.imageView.setImage(from: data.link)
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
        
    
    // ----- 코드 수정 제한 영역 시작 -----
    private func setNavigationBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonDidTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(changeButtonDidTap))
    }

    private func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(countDownloadedImages), name: .init("DownloadImageDidFinish"), object: nil)
    }
    // ----- 코드 수정 제한 영역 끝 -----

    /// 새로고침 버튼을 누르면 실행되는 함수
    ///
    /// 데이터를 처음부터 다시 불러 오고 컬렉션뷰의 스크롤을 최상단으로 위치시킨다.
    @objc func refreshButtonDidTap() {
        isRefresing = true
        isFetching = true
        viewModel.refreshImages()
    }

    /// Change 버튼을 누르면 실행되는 함수
    ///
    /// 컬렉션뷰의 레이아웃을 단일 컬럼과 3중 컬럼으로 번갈아가며 보여준다.
    @objc func changeButtonDidTap() {
        // 3분할 하는게....   구글링을 못하니까 기억이 안나네요 ㅠㅠㅠ
        // 어떤 Delegate 메서드에서 했었는지가.. ㅠㅠㅠ
        isFetching = true
        isListMode = !isListMode
        viewModel.refreshImages()
    }

    /// Image 다운로드를 완료할 때마다 불리는 함수
    @objc func countDownloadedImages() {
        let cnt = self.viewModel.getDataCount()
        // ----- 코드 수정 제한 영역 시작 -----
        self.imageCount += 1
        // ----- 코드 수정 제한 영역 끝 -----
        print("\(cnt) / \(self.imageCount)")
    }
}
