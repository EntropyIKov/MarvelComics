//
//  CellToDetails3DTransition.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 22/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class CellToDetails3DTransition: NSObject {
    var duration = 2.0
    var reverse = false
    let m34Const: CGFloat = 0.0
}

extension CellToDetails3DTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: .to)!
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toView = toViewController.view!
        let fromView = fromViewController.view!
        let direction: CGFloat = reverse ? -1 : 1
        
        toView.frame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
        containerView.addSubview(toView)

        
        let parameters = UICubicTimingParameters(animationCurve: .linear)
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        
        animator.addAnimations {
            toView.frame = containerView.frame
        }
        
        animator.addCompletion { _ in
//            containerView.transform = CGAffineTransform.identity
//
//            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//            if (transitionContext.transitionWasCancelled) {
//                toView.removeFromSuperview()
//            } else {
//                fromView.removeFromSuperview()
//            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
        return animator
    }
}
