//
//  CellToDetailsAnimationTransition.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 22/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class CellToDetailsAnimationTransition: NSObject {
    var duration = 0.7
    var reverse = false
    var startingPoint = CGPoint.zero
}

extension CellToDetailsAnimationTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let containerView = transitionContext.containerView
        
        let offScreenRight = CGAffineTransform(translationX: containerView.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -containerView.frame.width, y: 0)
        
        toView.transform = !reverse ? offScreenRight : offScreenLeft
        
        toView.layer.anchorPoint = CGPoint(x: 0, y: 0)
        fromView.layer.anchorPoint = CGPoint(x: 0, y: 0)
        
        toView.layer.position = CGPoint(x: 0, y: 0)
        fromView.layer.position = CGPoint(x: 0, y: 0)
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        
        animator.addAnimations {
            fromView.transform = !self.reverse ? offScreenLeft : offScreenRight
            toView.transform = CGAffineTransform.identity
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            toView.transform = CGAffineTransform.identity
            fromView.transform = CGAffineTransform.identity
        }
        
        return animator
    }
    
    
}
