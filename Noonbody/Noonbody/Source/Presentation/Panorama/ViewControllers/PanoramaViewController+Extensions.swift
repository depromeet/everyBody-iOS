//
//  PanoramaViewController+Extensions.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/22.
//

import UIKit

extension PanoramaViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bottomCollectionView {
            cellWidth = collectionView.frame.height * 0.54 + cellSpacing
            return CGSize(width: cellWidth, height: collectionView.frame.height )
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
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == topCollectionView && gridMode || editMode ? 2 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSelectedEvent { return }
        
        if scrollView == bottomCollectionView && !bodyPartData.isEmpty {
            let centerPoint = CGPoint(x: bottomCollectionView.contentOffset.x + bottomCollectionView.frame.midX, y: 100)
            
            if let indexPath = bottomCollectionView.indexPathForItem(at: centerPoint), centerCell == nil {
                centerCell = bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell
                topCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                selectedIndexByPart[bodyPart] = indexPath
                centerCell?.transformToCenter()
            }
            
            if let cell = centerCell {
                let offsetX = centerPoint.x - cell.center.x
                if offsetX < -cell.frame.width/2 || offsetX > cell.frame.width/2 {
                    cell.transformToStandard()
                    bottomCollectionView.deselectItem(at: selectedIndexByPart[bodyPart], animated: false)
                    self.centerCell = nil
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveCellToCenter(animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isSelectedEvent = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            moveCellToCenter(animated: true)
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
        if indexPath.item == selectedIndexByPart[bodyPart].row {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView && editMode {
            if indexPath.row == 0 {
                cameraButtonDidTap()
            } else {
                deleteData[indexPath.row - 1] = bodyPartData[indexPath.row - 1].id
            }
        } else if !bodyPartData.isEmpty {
            if selectedIndexByPart[bodyPart] == indexPath { return }
            isSelectedEvent = true
            centerCell?.transformToStandard()
            selectedIndexByPart[bodyPart] = indexPath
            
            guard let bottomCell = bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell else { return }
            centerCell = bottomCell
            setCollectionViewContentOffset(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView && editMode {
            deleteData.removeValue(forKey: indexPath.row - 1)
        }
    }
}
