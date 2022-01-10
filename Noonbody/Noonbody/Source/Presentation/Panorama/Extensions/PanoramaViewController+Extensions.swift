//
//  PanoramaViewController+Extensions.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/22.
//

import UIKit

let cellSpacing: CGFloat = 2

extension PanoramaViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bottomCollectionView {
            return CGSize(width: collectionView.frame.height * 0.54 + cellSpacing, height: collectionView.frame.height )
        } else {
            let length =  Constant.Size.screenWidth
            let ratio = UIDevice.current.hasNotch ? (4.0/3.0) : (423/375)
            return gridMode || editMode ?  CGSize(width: (length - 4)/3, height: (length - 4)/3) : CGSize(width: length, height: length * ratio)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bottomCollectionView {
            let inset = (collectionView.frame.width - (collectionView.frame.height * 0.54 + cellSpacing)) / 2
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == topCollectionView ? 2 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == bottomCollectionView {
            let centerPoint = CGPoint(x: bottomCollectionView.contentOffset.x + bottomCollectionView.frame.midX, y: 100)
            
            if let indexPath = self.bottomCollectionView.indexPathForItem(at: centerPoint), self.centerCell == nil {
                self.centerCell = self.bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell
                self.centerCell?.transformToCenter()
                topCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                tagSelectedIdx = indexPath
            } else if self.centerCell == nil {
                centerCell?.transformToStandard()
                bottomCollectionView.scrollToItem(at: tagSelectedIdx, at: .centeredHorizontally, animated: true)
            }
            
            if let cell = centerCell {
                let offsetX = centerPoint.x - cell.center.x
                if offsetX < -cell.frame.width/2 || offsetX > cell.frame.width/2 {
                    cell.transformToStandard()
                    self.centerCell = nil
                }
            }
        }
    }
    
    private func moveCellToCenter() {
        let centerPoint = CGPoint(x: bottomCollectionView.contentOffset.x + bottomCollectionView.frame.midX, y: 100)
        if let indexPath = bottomCollectionView.indexPathForItem(at: centerPoint) {
            bottomCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            topCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            self.centerCell = self.bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell
            self.centerCell?.transformToCenter()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveCellToCenter()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        moveCellToCenter()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            moveCellToCenter()
        }
    }
}

extension PanoramaViewController: UICollectionViewDataSource {
    typealias CameraCell = CameraCollectionViewCell
    typealias TopCell = TopCollectionViewCell
    typealias BottomCell = BottomCollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == topCollectionView && editMode ? bodyPartData.count + 1 : bodyPartData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            if editMode && indexPath.row == 0 {
                let cell: CameraCell = collectionView.dequeueReusableCell(for: indexPath)
                return cell
            }
            
            let cell: TopCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.selectedViewIsHidden(editMode: editMode)
            let indexPath = editMode ? indexPath.row - 1 : indexPath.row
            cell.setPhotoCell(imageURL: bodyPartData[indexPath].imageURL, contentMode: gridMode)
            return cell
        }
        
        let cell: BottomCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setCell(index: indexPath.row, imageURL: bodyPartData[indexPath.row].imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return collectionView == topCollectionView ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView && editMode {
            indexPath.row == 0 ? cameraButtonDidTap() : deleteData.append(bodyPartData[indexPath.row-1].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView && editMode {
            deleteData.removeAll(where: {$0 == bodyPartData[indexPath.row-1].id})
        }
    }
}
