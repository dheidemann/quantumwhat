
import SpriteKit

enum CollisionTypesTest: UInt32 {
    case qubit = 1
    case line = 2
    case atom = 4
}

public class QuantumTestScene: SKScene, SKPhysicsContactDelegate {
    
    
    public override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self //set physics contact delegate
        
        //background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg-mol.jpg")))
        bg.setScale(1.5)
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX , y: frame.midY)
        bg.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(bg)
        self.backgroundColor = SKColor.black
        
        //prof
        let profQuantum = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "normalProf.png")))    
        profQuantum.position = CGPoint(x: frame.midX + 400, y: frame.midY - 50)
        addChild(profQuantum)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 4)
        moveUp.timingMode = SKActionTimingMode.easeInEaseOut //set the timingmode of skaction
        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
        
        profQuantum.run(SKAction.repeatForever(sequence))
        
        //qubit
        let qb = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "qb.png")), color: .clear, size: CGSize(width: 290, height: 290))
        qb.position = CGPoint(x: frame.midX / 2, y: frame.midY)
        qb.name = "qubit"
        qb.physicsBody = SKPhysicsBody(circleOfRadius: max(qb.size.width / 3, qb.size.height / 3))
        qb.physicsBody?.categoryBitMask = CollisionTypes.qubit.rawValue
        qb.physicsBody?.contactTestBitMask = CollisionTypes.atom.rawValue
        qb.physicsBody?.affectedByGravity = false
        qb.physicsBody?.isDynamic = false
        addChild(qb)
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Qubit"
        label.fontColor = SKColor.white
        label.position = CGPoint(x: frame.midX - 400, y: frame.midY - 200)
        addChild(label)
        
        let arrowQB = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "arrow-qb.png")))
        arrowQB.position = CGPoint(x: frame.midX - 450, y: frame.midY - 100)
        addChild(arrowQB)
        
        let arrow = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "arrow.png")), color: .clear, size: CGSize(width: size.width * 0.03, height: size.width * 0.01))
        arrow.position = CGPoint(x: frame.midX / 2, y: frame.midY - 15)
        arrow.zPosition = 2
        arrow.anchorPoint = CGPoint(x: 0.0, y: 0.1)
        addChild(arrow)
        
        //animate arrow
        func arrowAnimationNorm(){
            arrow.zRotation = -0.05
            let animationUp = SKAction.rotate(byAngle: 0.1, duration: 0.5)
            let animationDown = SKAction.rotate(byAngle: -0.1, duration: 0.5)
            arrow.run(SKAction.repeatForever(SKAction.sequence([animationUp, animationDown])))
        }
        arrowAnimationNorm()
        
        //fourth card
        let fourthCard = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "fourthCard.png")))
        fourthCard.position = CGPoint(x: frame.midX / 2, y: frame.midY + 400)
        fourthCard.name = "fourthCard"
        addChild(fourthCard)
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        let nodeA = contactA.node 
        let nodeB = contactB.node 
        
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            
            print("qubit hit")
            
            removeFromParent()
            spawnAtom(position: CGPoint(x: 0.0, y: 0.0), moveTo: CGPoint(x: frame.midX - 450, y: frame.midY))
            
        }
        
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            
            let remove = SKAction.removeFromParent()
            let fade:SKAction = SKAction.fadeOut(withDuration: 0.2)
            fade.timingMode = .easeIn
            
            nodeA?.run(SKAction.sequence([fade, remove]))
            nodeB?.run(SKAction.sequence([fade, remove]))
            
            let scene = StartView(size: self.size)
            let transition = SKTransition.moveIn(with: .down, duration: 1.5)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view?.presentScene(scene)
            
        }
        
        if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
            
            print("crossed border")
            
            
        }  
        
    }
    
    //drag line to defeat the qubit
    
    var pathArray = [CGPoint()]
    
    
    func touchDown(atPoint pos: CGPoint) {
        pathArray.removeAll()
        pathArray.append(pos)
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        pathArray.append(pos)
    }
    
    func touchUp(atPoint pos: CGPoint) {
        createLine()
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            let location = t.location(in: self)
            var touchedNode = self.atPoint(location)
            
            self.touchDown(atPoint: t.location(in: self)) 
            
            if touchedNode == childNode(withName: "atom"){
                let fade:SKAction = SKAction.fadeOut(withDuration: 0.5)
                fade.timingMode = .easeIn
                let remove: SKAction = SKAction.removeFromParent()
                
                touchedNode.run(SKAction.sequence([fade, remove]))
                
            }
            
            if touchedNode == childNode(withName: "fourthCard"){
                
                let remove: SKAction = SKAction.removeFromParent()
                touchedNode.run(SKAction.sequence([remove]))
                
                let fifthCard = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "fifthCard.png")))
                fifthCard.position = CGPoint(x: frame.midX / 2, y: frame.midY + 400)
                fifthCard.name = "fifthCard"
                addChild(fifthCard)                
                
            }else if touchedNode == childNode(withName: "fifthCard") {
                
                let remove: SKAction = SKAction.removeFromParent()
                touchedNode.run(SKAction.sequence([remove]))
                
                let sixthCard = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "sixthCard.png")))
                sixthCard.position = CGPoint(x: frame.midX / 2, y: frame.midY + 400)
                sixthCard.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                sixthCard.name = "sixthCard"
                addChild(sixthCard)
                
                spawnAtom(position: CGPoint(x: 0.0, y: 0.0), moveTo: CGPoint(x: frame.midX - 450, y: frame.midY))
                
            }else if touchedNode == childNode(withName: "sixthCard") {
                
                let scene = StartView(size: self.size)
                let transition = SKTransition.moveIn(with: .down, duration: 1.5)
                scene.scaleMode = SKSceneScaleMode.aspectFill
                self.view?.presentScene(scene)
                
            }
        }
    }
    
    
    //drag a line to defend the qubit
    
    func createLine() {
        let path = CGMutablePath()
        path.move(to: pathArray[0])
        
        for point in pathArray {
            path.addLine(to: point)
        }
        
        let line = SKShapeNode(path: path)       
        line.path = path
        //line.fillColor = .clear
        line.lineWidth = 1
        line.zPosition = 3
        line.strokeColor = .cyan
        line.lineCap = .round
        line.glowWidth = 20
        line.name = "line"
        
        line.physicsBody = SKPhysicsBody(polygonFrom: path)
        line.physicsBody?.affectedByGravity = false
        line.physicsBody?.isDynamic = false
        line.physicsBody?.categoryBitMask = CollisionTypes.line.rawValue
        line.physicsBody?.contactTestBitMask = CollisionTypes.atom.rawValue
        
        self.addChild(line)
        
        let wait = SKAction .wait(forDuration: 1.5)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 1)
        fade.timingMode = .easeIn
        let remove: SKAction = SKAction.removeFromParent()
        
        line.run(SKAction.sequence([wait, fade, remove]))
        
    }
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { 
            self.touchMoved(toPoint: t.location(in: self)) 
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        
    }
    
    func spawnAtom(position:CGPoint, moveTo:CGPoint){
        
        let atom = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "atom.png")), size: CGSize(width: 100, height: 100))
        
        atom.position = position
        atom.name = "atom"
        atom.physicsBody = SKPhysicsBody(rectangleOf: atom.size)
        atom.physicsBody?.affectedByGravity = false
        atom.physicsBody?.isDynamic = true
        atom.physicsBody?.collisionBitMask = 0
        atom.physicsBody?.categoryBitMask = CollisionTypes.atom.rawValue
        
        let move = SKAction.move(to: moveTo,duration: 8) //speed of nodes
        
        //rotation animation for atoms
        var randomRotation = CGFloat.random(in: -1..<1)
        let rotateAtom = SKAction.rotate(byAngle: randomRotation, duration: 2)
        atom.run(SKAction.repeatForever(rotateAtom))
        
        atom.run(move)
        
        self.addChild(atom)
        
    }
}
