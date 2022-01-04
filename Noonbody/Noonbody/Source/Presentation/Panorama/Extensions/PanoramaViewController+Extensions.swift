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
            return CGSize(width: collectionView.frame.height * 0.54, height: collectionView.frame.height )
        } else {
            let length =  Constant.Size.screenWidth
            let ratio = UIDevice.current.hasNotch ? (4.0/3.0) : (423/375)
            return gridMode || editMode ?  CGSize(width: (length - 4)/3, height: (length - 4)/3) : CGSize(width: length, height: length * ratio)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bottomCollectionView {
            let inset = (topCollectionView.frame.width - 48) / 2
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == bottomCollectionView {
            let centerX = bottomCollectionView.frame.size.width / 2 + scrollView.contentOffset.x
            let centerY = bottomCollectionView.frame.size.height / 2 + scrollView.contentOffset.y
            let centerPoint = CGPoint(x: centerX, y: centerY)
            
            if let indexPath = self.bottomCollectionView.indexPathForItem(at: centerPoint), self.centerCell == nil {
                /// 중간 좌표에 있는 셀이 있을 때, 센터 셀이 nil이라면 그 아이템을 얘를 센터 셀에 넣어주고 함수 실행
                self.centerCell = self.bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell
                self.centerCell?.transformToCenter()
                topCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                tagSelectedIdx = indexPath
            } else if self.centerCell == nil {
                /// 중간에 걸려있는 인덱스가 없는데 센터 셀이 비어있을 때, itemspacing 사이에 걸려있는 상황
                centerCell?.transformToStandard()
            }
            
            if let cell = centerCell {
                let offsetX = centerPoint.x - cell.center.x
                if offsetX < -cell.frame.width/2 || offsetX > cell.frame.width/2 {
                    /// 중간에 있던 셀이 좌표를 벗어나면 nil로 만들어주고 원래 상태로 돌아가는 함수 실행
                    cell.transformToStandard()
                    self.centerCell = nil
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        bottomCollectionView.scrollToItem(at: tagSelectedIdx, at: .centeredHorizontally, animated: false)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView && editMode {
            deleteData.append(bodyPartData[indexPath.row-1].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView && editMode {
            deleteData.removeAll(where: {$0 == bodyPartData[indexPath.row-1].id})
        }
    }
}

