//
//  CellToDetailsTransition.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 19/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class CellToDetailsTransitionAnimator: NSObject {
    
    //MARK: - Property
    private var animatorForCurrentTransition: UIViewImplicitlyAnimating?
    var transitionMode: CircularTransitionMode = .present
    var circle: UIView? = UIView()
    var circleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var duration = 0.7
    
    var startingPoint = CGPoint.zero {
        didSet {
            circle?.center = startingPoint
        }
    }
    
    //MARK: - Init
    override init() {
        super.init()
    }
    
    init(startingPoint: CGPoint, circleColor: UIColor, mode: CircularTransitionMode) {
        self.startingPoint = startingPoint
        self.circleColor = circleColor
        transitionMode = mode
    }
}

extension CellToDetailsTransitionAnimator {
    enum CircularTransitionMode: Int {
        case present, dismiss, pop
    }
}

extension CellToDetailsTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if let animatorForCurrentSession = animatorForCurrentTransition {
            return animatorForCurrentSession
        }
        
        let containerView = transitionContext.containerView
        
        if transitionMode == .present {
            let presentedView = transitionContext.view(forKey: .to)!
            let fromView = transitionContext.view(forKey: .from)!
            let viewSize = fromView.frame.size
            
            circle = UIView()
        
            circle?.frame = frameForCircle(viewSize: viewSize, startPoint: startingPoint)
            circle?.layer.cornerRadius = (circle?.frame.size.height)! / 2
            circle?.clipsToBounds = true
            circle?.center = startingPoint
            circle?.backgroundColor = circleColor
            circle?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            if let circle = circle {
                containerView.addSubview(circle)
            }
            
//            presentedView.alpha = 0
            presentedView.alpha = 1
            presentedView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
            
            containerView.addSubview(presentedView)
            let duration = transitionDuration(using: transitionContext)
            
            let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
            let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
            
            animator.addAnimations { [weak self] in
                UIView.animateKeyframes(withDuration: duration, delay: 0, animations:{
                    
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75) {
                        self?.circle?.transform = CGAffineTransform.identity
                        presentedView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                        self?.circle?.transform = CGAffineTransform.identity
                        presentedView.alpha = 1
                        presentedView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
                    }
                })
            }
            
            animator.addCompletion { [weak self] _ in
                presentedView.alpha = 1
                presentedView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
                self?.circle?.transform = CGAffineTransform.identity
                self?.animatorForCurrentTransition = nil
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            animatorForCurrentTransition = animator
            return animator
        } else {
            // Dismiss
            let returningView: UIView
            let fromView: UIView
            if transitionMode == .pop {
                returningView = transitionContext.viewController(forKey: .to)!.view!
                fromView = transitionContext.viewController(forKey: .from)!.view!
            } else {
                returningView = transitionContext.viewController(forKey: .from)!.view!
                fromView = transitionContext.viewController(forKey: .to)!.view!
            }
            
            let viewCenter = returningView.center
            returningView.alpha = 1.0
            fromView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
            
            let duration = transitionDuration(using: transitionContext)
            let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
            let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
            
            animator.addAnimations { [weak self] in
                
                UIView.animateKeyframes(withDuration: duration, delay: 0, animations:{
                    
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75) {
                        self?.circle?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                        self?.circle?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    }
                })

                if self?.transitionMode == .pop {
                    containerView.insertSubview(returningView, belowSubview: fromView)
                    if let circle = self?.circle {
                        containerView.insertSubview(circle, belowSubview: fromView)
                    }
                }
            }
            
            animator.addCompletion { [weak self] _ in
                returningView.center = viewCenter
                self?.circle?.removeFromSuperview()
                returningView.alpha = 1
                self?.animatorForCurrentTransition = nil
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            animatorForCurrentTransition = animator
            return animator
        }
    }
    
    func frameForCircle(viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offssetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offssetVector, height: offssetVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
}
