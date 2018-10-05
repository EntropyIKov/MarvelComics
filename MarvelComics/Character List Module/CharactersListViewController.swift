//
//  CharactersListViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class CharactersListViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var logOutNavigationBar: LogOutNavigationBar!
    
    //MARK: - Variables
    var characters: [Character] = []
    var nextPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListOfCharacter(from: nextPage)
    }
    
    func setupView() {
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        logOutNavigationBar.parentViewController = self
    }
    
    func getListOfCharacter(from page: Int) {
        RequestManager.sharedInstance.getCharacters(page: page) { characters in
            self.characters.insert(contentsOf: characters, at: self.characters.count)
        }
        nextPage += 1
        charactersCollectionView.reloadData()
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// UICollectionViewDelegate, UICollectionViewDataSource
extension CharactersListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCellIdentifier = "CharacterImageIdentifier"
        let nameCellIdentifier = "CharacterNameIdentifier"
        let character = characters[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as? ImageCollectionViewCell {
            cell.populate(by: character)
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellIdentifier, for: indexPath) as? NameCollectionViewCell {
            cell.populate(by: character)
            return cell
        } else {
            fatalError("The dequeued cell is not an instance of \(imageCellIdentifier) and \(nameCellIdentifier)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 300
        if maxOffset - currentOffset < maxScrollDiff {
            getListOfCharacter(from: nextPage)
        }
    }
    // ContentOffset ScrollViewDidSCroll
}
