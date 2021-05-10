
import SpriteKit
import AVFoundation


enum CollisionTypes: UInt32 {
    case qubit = 1
    case line = 2
    case atom = 4
}


public class QuantumGameScene:SKScene, SKPhysicsContactDelegate{    
    
    var levelTimerLabel = SKLabelNode(fontNamed: "Chalkduster")
    var timerIsOver = false
    
    //Immediately after leveTimerValue variable is set, update label's text
    var levelTimerValue: Int = 30 {
        didSet {
            levelTimerLabel.text = "Time left: \(levelTimerValue)s"
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    
    func playAudio() { 
        if let audioURL = Bundle.main.url(forResource: "pop", withExtension: "wav") {
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL) /// make the audio player
                self.audioPlayer?.numberOfLoops = 0 /// Number of times to loop the audio
                self.audioPlayer?.play() /// start playing
                audioPlayer?.volume = 0.2
                
            } catch {
                print("Couldn't play audio. Error: \(error)")
            }
            
        } else {
            print("No audio file found")
        }
    }
    
    func timerOver(defeat: Bool) {
        let scene = WonScreen(size: self.size)
        let transition = SKTransition.moveIn(with: .down, duration: 1.5)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        self.view?.presentScene(scene)
    }
    
    func arrow() {
        //arrow
        let arrow = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "arrow.png")), color: .clear, size: CGSize(width: size.width * 0.03, height: size.width * 0.01))
        arrow.position = CGPoint(x: frame.midX, y: frame.midY - 15)
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
        
        func arrowAnimationBig() {
            arrow.zRotation = -0.3
            let animationUp = SKAction.rotate(byAngle: 0.6, duration: 0.5)
            let animationDown = SKAction.rotate(byAngle: -0.6, duration: 0.5)
            arrow.run(SKAction.repeatForever(SKAction.sequence([animationUp, animationDown])))
        }
        
        arrowAnimationNorm()
        
    }
    
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        //controll what to do in case of collisions
        
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        let nodeA = contactA.node 
        let nodeB = contactB.node 
        
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 { //atom and qubit
                
            let scene = GameOver(size: self.size)
            let transition = SKTransition.moveIn(with: .down, duration: 1.5)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view?.presentScene(scene)
 
        }
        
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 { //atom and line
            
            let remove = SKAction.removeFromParent()
            let fade:SKAction = SKAction.fadeOut(withDuration: 0.2)
            fade.timingMode = .easeIn
            
            nodeA?.run(SKAction.sequence([fade, remove]))
            nodeB?.run(SKAction.sequence([fade, remove]))
            
            playAudio()
            
        }
        
    }
    
    
    public override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self //set physics contact delegate
        
        //background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg-mol.jpg")))
        bg.setScale(1.5)
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
        //qubit
        let qb = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "qb.png")), color: .clear, size: CGSize(width: 290, height: 290))
        qb.position = CGPoint(x: frame.midX, y: frame.midY)
        qb.name = "qubit"
        qb.physicsBody = SKPhysicsBody(circleOfRadius: max(qb.size.width / 3, qb.size.height / 3))
        qb.physicsBody?.categoryBitMask = CollisionTypes.qubit.rawValue
        qb.physicsBody?.contactTestBitMask = CollisionTypes.atom.rawValue
        qb.physicsBody?.affectedByGravity = false
        qb.physicsBody?.isDynamic = false
        addChild(qb)        
        
            //timer declaration
        levelTimerLabel.fontColor = SKColor.white
        levelTimerLabel.fontSize = 40
        levelTimerLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 350)
        levelTimerLabel.text = "Time left: \(levelTimerValue)s"
        addChild(levelTimerLabel)
        
        if !timerIsOver {
            
            let wait = SKAction.wait(forDuration: 1) //countdown speed
            let block = SKAction.run({
                [unowned self] in
                
                if self.levelTimerValue > 0{
                    self.levelTimerValue -= 1
                }else{
                    timerIsOver = true
                    timerOver(defeat: false)
                }
                
            })
            let sequence = SKAction.sequence([wait,block])
            
            run(SKAction.repeatForever(sequence))
            
        }
        
        arrow() //create arrow in the middle
        
        createAtoms() //spawn random atoms
        
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
            
            self.touchDown(atPoint: t.location(in: self)) 
            
            let location = t.location(in: self)
            var touchedNode = self.atPoint(location)
            
            if touchedNode == childNode(withName: "atom"){
                let fade:SKAction = SKAction.fadeOut(withDuration: 0.5)
                fade.timingMode = .easeIn
                let remove: SKAction = SKAction.removeFromParent()
                
                touchedNode.run(SKAction.sequence([fade, remove]))
                
            }
        }
    }
    
    
    //line properties
    func createLine() {
        let path = CGMutablePath()
        path.move(to: pathArray[0])
        
        for point in pathArray {
            path.addLine(to: point)
        }
        
        let line = SKShapeNode(path: path)       
        line.path = path
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
    
    
    
    //helper func for following random point
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        
    }
    
    //generate point between two numbers -> later usefull for spawning enemys at random points
    func randomPointBetween(start:CGPoint, end:CGPoint)->CGPoint{
        
        return CGPoint(x: randomBetweenNumbers(firstNum: start.x, secondNum: end.x), y: randomBetweenNumbers(firstNum: start.y, secondNum: end.y))
        
    }
    
    //func to spawn random atoms outside the screen
    func createAtoms(){
        
        //spawning time
        let wait = SKAction .wait(forDuration: 1.2, withRange: 0.2)
        
        weak var  weakSelf = self //weakSelf to break a possible strong reference cycle
        
        let spawn = SKAction.run({
            
            var random = arc4random() % 4 +  1 //create random number between 1 and 4 to randomize following switch
            var position = CGPoint()
            var moveTo = CGPoint()
            var offset:CGFloat = 40
            
            switch random {
            
            //top to bottom
            case 1:
                position = weakSelf!.randomPointBetween(start: CGPoint(x: 0, y: weakSelf!.frame.height), end: CGPoint(x: weakSelf!.frame.width, y: weakSelf!.frame.height))
                moveTo = weakSelf!.randomPointBetween(start: CGPoint(x: 0, y: 0), end: CGPoint(x:weakSelf!.frame.width, y:0))
                
                break
                
            //bottom to top
            case 2:
                position = weakSelf!.randomPointBetween(start: CGPoint(x: 0, y: 0), end: CGPoint(x: weakSelf!.frame.width, y: 0))
                moveTo = weakSelf!.randomPointBetween(start: CGPoint(x: 0, y: weakSelf!.frame.height), end: CGPoint(x: weakSelf!.frame.width, y: weakSelf!.frame.height))
                
                break
                
            //left to right
            case 3:
                position = weakSelf!.randomPointBetween(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: weakSelf!.frame.height))
                moveTo = weakSelf!.randomPointBetween(start: CGPoint(x: weakSelf!.frame.width, y: 0), end: CGPoint(x: weakSelf!.frame.width, y: weakSelf!.frame.height))
                
                break
                
            //right to left
            case 4:
                position = weakSelf!.randomPointBetween(start: CGPoint(x: weakSelf!.frame.width, y: 0), end: CGPoint(x: weakSelf!.frame.width, y: weakSelf!.frame.height))
                moveTo = weakSelf!.randomPointBetween(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: weakSelf!.frame.height))
                break
                
            default:
                break
                
            }
            
            weakSelf!.spawnAtom(position: position, moveTo: moveTo)
            
        })
        
        let spawning = SKAction.sequence([wait,spawn])
        
        self.run(SKAction.repeatForever(spawning), withKey:"spawning")
        
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
        
        let move = SKAction.move(to: moveTo,duration: 9) //speed of nodes
        let remove = SKAction.removeFromParent()
        
        //rotation animation for atoms
        var randomRotation = CGFloat.random(in: -1..<1)
        let rotateAtom = SKAction.rotate(byAngle: randomRotation, duration: 2)
        atom.run(SKAction.repeatForever(rotateAtom))
        
        atom.run(SKAction.sequence([move, remove]))
        
        self.addChild(atom)
        
    }
    
}
