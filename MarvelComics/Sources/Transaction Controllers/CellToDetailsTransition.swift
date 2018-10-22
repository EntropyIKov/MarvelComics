//
//  CellToDetailsTransition.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 22/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class CellToDetailsTransition: NSObject {
    var duration = 0.7
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
}

extension CellToDetailsTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        
        toViewController.view.frame = finalFrameForVC
        containerView.addSubview(toViewController.view)
        containerView.sendSubviewToBack(toViewController.view)
        
        var snapshotView: UIView?
        var oldSnapshotView: UIView?
        if isPresenting {
            snapshotView = toViewController.view.snapshotView(afterScreenUpdates: true)
            snapshotView?.frame = fromViewController.view.frame
            snapshotView?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            oldSnapshotView = fromViewController.view.snapshotView(afterScreenUpdates: false)
            if let oldSnapshotView = oldSnapshotView {
                containerView.addSubview(oldSnapshotView)
            }
            
        } else {
            snapshotView = fromViewController.view.snapshotView(afterScreenUpdates: false)
            snapshotView?.frame = fromViewController.view.frame
        }
        
        
        
        if let snapshotView = snapshotView {
            containerView.addSubview(snapshotView)
        }
        
        fromViewController.view.removeFromSuperview()
        
        let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        
        animator.addAnimations { [weak self] in
            
            UIView.animateKeyframes(withDuration: duration, delay: 0.0, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.50) {
                    
                    if let self = self, !self.isPresenting {
                        snapshotView?.alpha = 0
                    }
                }
            })
            if let self = self, !self.isPresenting {
                snapshotView?.frame = fromViewController.view.frame.insetBy(dx: fromViewController.view.frame.size.width / 2, dy: fromViewController.view.frame.size.height / 2)
            } else {
                snapshotView?.transform = CGAffineTransform.identity
            }
        }
        
        animator.addCompletion { _ in
            snapshotView?.removeFromSuperview()
            oldSnapshotView?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        return animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    
}
