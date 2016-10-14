//
//  ViewController.swift
//  DrawTogether
//
//  Created by Cody Miller on 10/7/16.
//  Copyright © 2016 seniorDesign. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var drawImage = UIImageView()
    var polylines: [Polyline] = []
    var currentPolyline: Polyline!
    var lastPoint: CGPoint!
    var liveQuery: CBLLiveQuery!

    override func viewDidLoad() {
        super.viewDidLoad()
        drawImage.frame = view.bounds
        view.addSubview(drawImage)
        
        liveQuery = kDatabase.createAllDocumentsQuery().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: [], context: nil)
        do {
            try liveQuery.run()
        } catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastPoint = (touches.first! as UITouch).locationInView(view)
        currentPolyline = Polyline()
        currentPolyline.points.append(["x" : lastPoint.x, "y" : lastPoint.y])
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = (touches.first! as UITouch).locationInView(view)
        currentPolyline.points.append(["x" : point.x, "y" : point.y])
        
        UIGraphicsBeginImageContext(view.bounds.size)
        drawImage.image?.drawInRect(view.bounds)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), .Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1)
        CGContextBeginPath(UIGraphicsGetCurrentContext())
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        lastPoint = point
    }
    
    @IBAction func clearTap(sender: AnyObject) {
        for polyline in polylines {
            do {
                try polyline.deleteDocument()
            } catch {
                
            }
        }
        polylines = []
        drawImage.image = nil
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        do {
        try currentPolyline.save()
        } catch {
            
        }

    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object as! CBLLiveQuery) == liveQuery {
            polylines.removeAll(keepCapacity: false)
            
            for (_, row) in liveQuery.rows.allObjects.enumerate() {
                polylines.append(Polyline(forDocument: (row as! CBLQueryRow).document))
            }
            
            drawPolylines()
        }
    }
 
    
    func drawPolylines() {
        drawImage.image = nil
        UIGraphicsBeginImageContext(view.bounds.size)
        drawImage.image?.drawInRect(view.bounds)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), .Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1)
        CGContextBeginPath(UIGraphicsGetCurrentContext())
        
        for polyline in polylines {
            if let firstPoint = polyline.points.first {
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), firstPoint["x"]!, firstPoint["y"]!)
            }
            
            for point in polyline.points {
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point["x"]!, point["y"]!)
            }
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }


}

