
import SpriteKit //for the game and animations
import AVFoundation //for the video appearing on the screen

public class explainFirst: SKScene {
    
    var playerLayer = AVPlayerLayer()
    
    
    //audio player for background music
    var audioPlayer: AVAudioPlayer?
    
    func playAudio() { 
        if let audioURL = Bundle.main.url(forResource: "bg-music", withExtension: "mp3") {
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL) //audio player
                self.audioPlayer?.numberOfLoops = -1 //loop
                self.audioPlayer?.play() //start playing
                audioPlayer?.volume = 0.15
                
            } catch {
                print("Couldn't play audio. Error: \(error)")
            }
            
        } else {
            print("No audio file found")
        }
    }
    
    public override func didMove(to view: SKView) {
        
        playAudio() //call func at the beginning
        
        //background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg-mol.jpg")))
        bg.setScale(1.5)
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX , y: frame.midY)
        bg.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(bg)
        
        self.backgroundColor = SKColor.black
        
            //first card
        let firstCard = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "firstCard.png")))
        firstCard.position = CGPoint(x: frame.midX - 400, y: frame.midY - 100)
        firstCard.name = "firstCard"
        addChild(firstCard)
        
        
            //prof
        let profQuantum = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "normalProf.png")))    
        profQuantum.position = CGPoint(x: frame.midX + 400, y: frame.midY)
        addChild(profQuantum)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 4)
        moveUp.timingMode = SKActionTimingMode.easeInEaseOut //set the timingmode of skaction
        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
        
        profQuantum.run(SKAction.repeatForever(sequence))
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            let location = t.location(in: self)
            var touchedNode = self.atPoint(location)
            
            if touchedNode == childNode(withName: "firstCard"){
                
                let remove: SKAction = SKAction.removeFromParent()
                touchedNode.run(SKAction.sequence([remove]))
                
                let secondCard = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "secondCard.png")))
                secondCard.position = CGPoint(x: frame.midX - 400, y: frame.midY - 100)
                secondCard.name = "secondCard"
                addChild(secondCard)
                
                var videoNode: SKVideoNode? = {
                    let url = Bundle.main.url(forResource: "map_serially", withExtension: "mp4") 
                    let item = AVPlayerItem(url: url!)
                    let player = AVQueuePlayer(playerItem: item)
                    playerLayer.player = player            
                    
                    //loop
                    player.actionAtItemEnd = .none
                    NotificationCenter.default.addObserver(self, selector: #selector(rewindVideo(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                    
                    return SKVideoNode(avPlayer: player)
                    
                }()
                
                videoNode?.position = CGPoint(x: frame.midX - 400, y: frame.midY + 430)
                addChild(videoNode!)
                videoNode?.play()
 
                
            }else if touchedNode == childNode(withName: "secondCard") {
                
                let remove: SKAction = SKAction.removeFromParent()
                touchedNode.run(SKAction.sequence([remove]))
                
                let thirdCard = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "thirdCard.png")))
                thirdCard.position = CGPoint(x: frame.midX - 400, y: frame.midY - 100)
                thirdCard.name = "thirdCard"
                addChild(thirdCard)
                
            }else if touchedNode == childNode(withName: "thirdCard") {
                
                    let scene = QuantumTestScene(size: self.size)
                    let transition = SKTransition.moveIn(with: .down, duration: 1.5)
                    scene.scaleMode = SKSceneScaleMode.aspectFill
                    self.view?.presentScene(scene)
                
            }
        }
    }
    @objc func rewindVideo(notification: Notification) {
        playerLayer.player!.seek(to: .zero)
    }
    
}


