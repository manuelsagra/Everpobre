//
//  Animator.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 16/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 1.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        containerView.addSubview(toView)
        toView.alpha = 0
        
        UIView.animate(
            withDuration: 1,
            animations: {
                toView.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
    }
}
