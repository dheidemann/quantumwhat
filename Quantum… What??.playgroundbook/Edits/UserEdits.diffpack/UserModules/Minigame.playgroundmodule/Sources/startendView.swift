import SpriteKit
import  AVFoundation

public class StartView: SKScene {    
    public override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        print("inside main menu")
        addPlayButton()
        
        //background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg-mol.jpg")))
        bg.setScale(1.5)
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
            //label
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Good Job! The program takes 30 seconds to boot. Let's go!"
        label.fontColor = SKColor.white
        label.position = CGPoint(x: frame.midX, y: frame.midY - 400)
        addChild(label)
        
        //prof
        let profQuantum = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "thumbsupProf.png")))    
        profQuantum.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        addChild(profQuantum)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 4)
        moveUp.timingMode = SKActionTimingMode.easeInEaseOut //set the timingmode of skaction
        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
        
        profQuantum.run(SKAction.repeatForever(sequence))
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if t == touches.first {
                print("going to gameplay")
                
                enumerateChildNodes(withName: "//*", using: { (node, stop) in
                    if node.name == "playButton" {
                        let scene = QuantumGameScene(size: self.size)
                        let transition = SKTransition.moveIn(with: .down, duration: 1.5)
                        scene.scaleMode = SKSceneScaleMode.aspectFill
                        self.view?.presentScene(scene)
                    }
                })
            }
        }
    }
    
    
    func addPlayButton() {
        let playButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "play_circle_filled.png")))
        playButton.name = "playButton"
        playButton.position = CGPoint(x: frame.midX, y: frame.midY - 120)
        addChild(playButton)
    }
    
}


public class GameOver: SKScene {
    public override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        print("inside main menu")
        addPlayButton()
        
        //background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg-mol.jpg")))
        bg.setScale(1.5)
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "The qubit got hit by an atom. Try again!"
        label.fontColor = SKColor.white
        label.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        addChild(label)
        
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if t == touches.first {
                print("going to gameplay")
                
                enumerateChildNodes(withName: "//*", using: { (node, stop) in
                    if node.name == "playButton" {
                        let scene = QuantumGameScene(size: self.size)
                        let transition = SKTransition.moveIn(with: .down, duration: 1.5)
                        scene.scaleMode = SKSceneScaleMode.aspectFill
                        self.view?.presentScene(scene)
                    }
                })
            }
        }
    }
    
    
    func addPlayButton() {
        let playButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "play_circle_filled.png")))
        playButton.name = "playButton"
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(playButton)
    }
}

public class WonScreen: SKScene {
    
    var playerLayer = AVPlayerLayer()
    
    var audioPlayer: AVAudioPlayer?
    
    func playAudio() { 
        if let audioURL = Bundle.main.url(forResource: "won", withExtension: "mp3") {
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL) //audio player
                self.audioPlayer?.numberOfLoops = 0 //loop
                self.audioPlayer?.play() //start playing
                audioPlayer?.volume = 0.9
                
            } catch {
                print("Couldn't play audio. Error: \(error)")
            }
            
        } else {
            print("No audio file found")
        }
    }
    
    public override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        playAudio()
        
        //background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg-mol.jpg")))
        bg.setScale(1.5)
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX / 2, y: frame.midY)
        bg.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(bg)
        
        self.backgroundColor = SKColor.black
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "You did it! Our navigation program works fine! Thank you!"
        label.fontColor = SKColor.white
        label.position = CGPoint(x: frame.midX - 650, y: frame.midY - 300)
        addChild(label)
        
        
        var videoNode: SKVideoNode? = {
            let url = Bundle.main.url(forResource: "map_simultan", withExtension: "mp4") 
            let item = AVPlayerItem(url: url!)
            let player = AVQueuePlayer(playerItem: item)
            playerLayer.player = player            
            
            //loop
            player.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(self, selector: #selector(rewindVideo(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            
            return SKVideoNode(avPlayer: player)
            
        }()
        
        videoNode?.position = CGPoint(x: frame.midX - 650, y: frame.midY + 300)
        addChild(videoNode!)
        videoNode?.play()
        
        //prof
        let profQuantum = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "happy.png")))    
        profQuantum.position = CGPoint(x: frame.midX + 400, y: frame.midY)
        addChild(profQuantum)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 4)
        moveUp.timingMode = SKActionTimingMode.easeInEaseOut //set the timingmode of skaction
        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
        
        profQuantum.run(SKAction.repeatForever(sequence))
        
    }
    @objc func rewindVideo(notification: Notification) {
        playerLayer.player!.seek(to: .zero)
    }
}

