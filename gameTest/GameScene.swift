//
//  GameScene.swift
//  gameTest
//
//  Created by Nathan Anderson on 3/23/18.
//  Copyright © 2018 Nathan Anderson. All rights reserved.
//

//
//  SKDestructibleNode.swift
//  SKDestructibleNode
//
//  Created by Trent Sartain on 12/13/15.
//  Copyright © 2015 Trent Sartain. All rights reserved.
//
import SpriteKit

//code to create destroyed pieces of apple

class SKDestructibleNode : SKSpriteNode {
    var pieces = Array<SKSpriteNode>()
    var isDestroyed = false
    var nodeScene : SKScene
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        nodeScene = SKScene()
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(imageName: String, scene: SKScene, pieceSize : CGFloat){
        self.init(imageNamed: imageName)
        self.nodeScene = scene
        
        createRectPieces(imageName: imageName, rectSize: CGSize(width: pieceSize, height: pieceSize))
    }
    
    convenience init(imageName: String, scene: SKScene, rectSize : CGSize){
        self.init(imageNamed: imageName)
        self.nodeScene = scene
        
        createRectPieces(imageName: imageName, rectSize: rectSize)
    }
    
    private func createRectPieces(imageName: String, rectSize : CGSize) {
        let xScale = (rectSize.width / self.size.width)
        let yScale = (rectSize.height / self.size.height)
        
        let numSquaresAcross = Int(self.size.width / rectSize.width) +  1
        let numSquaresUp = Int(self.size.height / rectSize.height) + 1
        
        let clone = SKSpriteNode(imageNamed: imageName)
        
        for i in 0 ..< numSquaresAcross {
            for j in 0 ..< numSquaresUp {
                let crop = SKCropNode()
                let mask = SKSpriteNode(color: UIColor.black, size: rectSize)
                mask.position = CGPoint(x: (CGFloat(i) * (rectSize.width)) + (rectSize.width/2) - self.size.width/2, y: (CGFloat(j) * (rectSize.height)) + (rectSize.height/2) - self.size.height/2)
                
                crop.addChild(clone)
                crop.maskNode = mask
                
                let spriteNode = SKSpriteNode(texture: nodeScene.view?.texture(from: crop), size: CGSize(width: rectSize.width / xScale, height: rectSize.height / yScale))
                spriteNode.physicsBody = SKPhysicsBody(texture: spriteNode.texture!, alphaThreshold: 0.01, size: spriteNode.size)
                
                //TODO: Images with no content fail to create physicsBodies.
                if spriteNode.physicsBody == nil { continue }
                
                pieces.append(spriteNode)
            }
        }
    }
    
    func destroy(collision : Bool) -> Array<SKSpriteNode> {
        if isDestroyed { return Array<SKSpriteNode>() }
        isDestroyed = true
        
        var angularVelocity : CGFloat = 0
        if let body = self.physicsBody {
            angularVelocity = body.angularVelocity
        }
        
        for piece in pieces {
            piece.xScale = self.xScale
            piece.yScale = self.yScale
            piece.position = self.position
            piece.zRotation = self.zRotation
            piece.physicsBody?.angularVelocity = angularVelocity
            piece.physicsBody?.affectedByGravity = true
            piece.physicsBody?.restitution = 0.2
            piece.physicsBody?.friction = 0.5
            
            if collision == false {
                
                piece.physicsBody?.collisionBitMask = 0
                
            }
            
            nodeScene.addChild(piece)
        }
        
        self.removeFromParent()
        return self.pieces
    }
    
    func destroyWithBoom(boomStrength : Float, atPoint : CGPoint, collision : Bool) -> Array<SKSpriteNode> {
        let fieldNode = SKFieldNode.radialGravityField()
        fieldNode.strength = -boomStrength
        fieldNode.position = atPoint
        nodeScene.addChild(fieldNode)
        nodeScene.run(SKAction.sequence([SKAction.wait(forDuration: 0.01), SKAction.removeFromParent()]))
        
        return destroy(collision: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////



import SpriteKit
import GameplayKit
import UIKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
   
    //~~~ initialize variables
    
    let gameVC = GameViewController()
    var ball = SKSpriteNode()
    var ground = SKSpriteNode()
    var firstTouch = CGPoint()
    var slowTimer = Timer()
    var slowMotion = SKSpriteNode()
    var slowAmmount : Int = 85
    var slowAddTimer = Timer()
    var enemy = SKSpriteNode()
    var enemyTimer = Timer()
    var gameTimer = Timer()
    var endTimer = Timer()
    var Counter = 3
    var countTime = SKLabelNode()
    var xplode = SKDestructibleNode()
    var coinEffect = SKDestructibleNode()
    var gameOver : Bool = false
    var flash = SKSpriteNode()
    let gameViewController = GameViewController()
    var coinPieces: Array<SKSpriteNode> = [SKSpriteNode()]
    var pieces: Array<SKSpriteNode> = [SKSpriteNode()]
    var coin = SKSpriteNode()
    var randomPosition : CGPoint = CGPoint()
    var score = 0
    var gameStatusLabel = SKLabelNode()
    var highscoreLabel = SKLabelNode()
    var menuLabel = SKLabelNode()
    var tryAgain = SKLabelNode()
    var coinTimer = Timer()
    var highscore = 0
    
   
    
    //~~~ Collision Detection
    func didBegin(_ contact: SKPhysicsContact){
        
        if ((contact.bodyA.node?.name == "ball" || contact.bodyB.node?.name == "ball")  && (contact.bodyA.node?.name == "enemy" || contact.bodyB.node?.name == "enemy")) {
            ball.physicsBody?.categoryBitMask = 0
            //print(contact.bodyA.node?.name ?? "error")
            //print(" - hit - ")
            //print(contact.bodyB.node?.name ?? "error")
            if gameOver == false{
                print("Game Over")
                xplode = SKDestructibleNode(imageName: "Apple.png", scene: self, rectSize: CGSize(width: 50, height: 100))
                self.addChild(xplode)
                
            xplode.position = ball.position
                
            ball.removeFromParent()
            
            pieces = xplode.destroyWithBoom(boomStrength: 0.005, atPoint: xplode.position, collision: true)
                slowTimer.invalidate()
                slowAddTimer.invalidate()
                gameStatusLabel.text = "Score: " + String(score)
                gameStatusLabel.isHidden = false
                
                flash.alpha = 1
                flash.run(SKAction.fadeOut(withDuration: 0.2))
                ground.physicsBody?.restitution = 0.2
                enemy.physicsBody?.affectedByGravity = true
                enemy.physicsBody?.restitution = 0.2
                enemy.physicsBody?.friction = 0.5
                enemyTimer.invalidate()
                self.physicsWorld.speed = 1
                endTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(gameEnd), userInfo: nil, repeats: false)
            }
        }
        if ((contact.bodyA.node?.name == "ball" || contact.bodyB.node?.name == "ball")  && (contact.bodyA.node?.name == "coin" || contact.bodyB.node?.name == "coin")) {
            
            print("collide")
            coin.physicsBody?.contactTestBitMask = 0
            coin.physicsBody?.collisionBitMask = 0
       coinCollected()
            
        }
        
    }
//////////////////////////////////////////////////////////////////////////
    
   
    
    override func didMove(to view: SKView) {
     
    //initialize objects and their collisions
        
         self.physicsWorld.contactDelegate = self
      
        
        flash = self.childNode(withName: "flash") as! SKSpriteNode
        flash.alpha = 0
        menuLabel = self.childNode(withName: "menuLabel") as! SKLabelNode
        gameStatusLabel = self.childNode(withName: "GameOver") as! SKLabelNode
        highscoreLabel = self.childNode(withName: "highScore") as! SKLabelNode
        countTime = self.childNode(withName: "Count") as! SKLabelNode
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ground = self.childNode(withName: "ground") as! SKSpriteNode
        slowMotion = self.childNode(withName: "slowMotion") as! SKSpriteNode
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
      coin = self.childNode(withName: "coin") as! SKSpriteNode
        tryAgain = self.childNode(withName: "tryAgain") as! SKLabelNode
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
       
        enemy.physicsBody?.categoryBitMask = 00000010
        border.categoryBitMask = 10000000
        ground.physicsBody?.categoryBitMask = 00000100
        xplode.physicsBody?.categoryBitMask = 00001000
        ball.physicsBody?.categoryBitMask = 00000001
        coin.physicsBody?.categoryBitMask = 01000000
        
        enemy.physicsBody?.collisionBitMask = 10000101
        border.collisionBitMask = 00000000
        ground.physicsBody?.collisionBitMask = 00001011
        xplode.physicsBody?.collisionBitMask = 00000110
        ball.physicsBody?.collisionBitMask = 100000110
        coin.physicsBody?.collisionBitMask = 00000000
        
        enemy.physicsBody?.contactTestBitMask = 00000001
        ground.physicsBody?.contactTestBitMask = 00000000
        ball.physicsBody?.contactTestBitMask = 01000010
        coin.physicsBody?.contactTestBitMask = 00000001
        
        self.physicsWorld.speed = 0
        setup()
        
    }
    
    //setup that runs every game
    func setup(){
        
        highscore = UserDefaults.standard.integer(forKey: "highscore")
        
        for piece in pieces {
            piece.removeFromParent()
        }
        xplode.removeFromParent()
        pieces.removeAll()
    
        menuLabel.isHidden = true
        slowTimer.invalidate()
        slowAddTimer.invalidate()
        tryAgain.isHidden = true
        gameStatusLabel.isHidden = true
        highscoreLabel.isHidden = true
        score = 0
        gameOver = false
        slowAmmount = 85
        slowMotion.position = CGPoint(x: slowMotion.position.x, y: 650)
        slowMotion.run(SKAction.resize(toWidth: CGFloat(slowAmmount), height: CGFloat(40), duration: 0))
         self.physicsWorld.speed = 0
        flash.alpha = 1
        ball.removeFromParent()
        self.addChild(ball)
        Counter = 3
        ball.position = CGPoint(x: 0,y: 0)
        ball.physicsBody?.angularVelocity = 0
        ball.zRotation = 0
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.pinned = true
        enemy.position = CGPoint(x: -275,y: 547)
        countTime.fontSize = 199
        updateCoinPosition()
        flash.run(SKAction.fadeOut(withDuration: 0.2))
        
        ground.physicsBody?.restitution = 1
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.restitution = 1
        enemy.physicsBody?.friction = 0.2
        enemy.physicsBody?.angularVelocity = 0
        enemy.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        enemy.zRotation = 0
         enemy.physicsBody?.pinned = true
        ball.physicsBody?.usesPreciseCollisionDetection = true
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        coin.physicsBody?.usesPreciseCollisionDetection = true
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        enemyTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(GameScene.enemyImpulse), userInfo: nil, repeats: true)
       
        print("Setup ran.")
        print(score)
    }
    
    ///////////////////
    //Touch handling//
    //////////////////
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ( gameOver == true){ //if menu button is touched
            
            if CGFloat((touches.first?.location(in: self).y)!) > CGFloat((slowMotion.position.y - 100)){
                gameVC.callMenu()
                self.view?.presentScene(nil)
            }else{
            
            for piece in pieces {
                piece.removeFromParent()
            }
            xplode.removeFromParent()
            print("running setup...")
            countTime.text = "3"
            setup()
            }
        } else{
        for touch in touches {
            
            self.physicsWorld.speed = 0.5
            firstTouch = touch.location(in: self)
            slowTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.slow), userInfo: nil, repeats: true)
            slowAddTimer.invalidate()
            
            }
        }
    }
    
    // Dragging Controls
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ( gameOver == false){
        for touch in touches {
           let currentTouch = touch.location(in: self)
            let deltaX = currentTouch.x - firstTouch.x
            let deltaY = currentTouch.y - firstTouch.y
            if slowAmmount > 0 {
            ball.run(SKAction.applyImpulse(CGVector(dx: deltaX*2, dy: deltaY*2), duration: 0.1)) //force impulse
            } else { self.physicsWorld.speed = 2 }
            firstTouch = currentTouch
            }
        } else {
            slowTimer.invalidate()
            slowAddTimer.invalidate()
            slowMotion.size.width = 85
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ( gameOver == false){
                    self.physicsWorld.speed = 2
                    slowTimer.invalidate()
        slowAddTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(addSlow), userInfo: nil, repeats: true)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        
        let vX = Int((self.ball.physicsBody?.velocity.dx)!)
        let vY = Int((self.ball.physicsBody?.velocity.dy)!)
        let velocityLimit = 500     // limit the velocity of the ball/knife
        
        if (vX > velocityLimit) {
            self.ball.physicsBody?.velocity.dx = CGFloat(velocityLimit)
        }
        if (vY > velocityLimit) {
            self.ball.physicsBody?.velocity.dy = CGFloat(velocityLimit)
        }
        if (vX < -velocityLimit) {
            self.ball.physicsBody?.velocity.dx = CGFloat(-velocityLimit)
        }
        if (vY < -velocityLimit) {
            self.ball.physicsBody?.velocity.dy = CGFloat(-velocityLimit)
        
    }
}
    
    @objc func slow(){
        if slowAmmount >= 4 {
        slowAmmount -= 4
            //print(slowAmmount)
        } else {
            slowAmmount = 0
            self.physicsWorld.speed = 2
            
        }
        slowMotion.run(SKAction.resize(toWidth: CGFloat(slowAmmount), duration: 0.1))
    //print(slowAmmount)
    }
    @objc func addSlow(){
        if slowAmmount < 85 {
        slowAmmount += 4
        } else {
         slowAmmount = 85
            slowTimer.invalidate()
        }
     
        //print(slowAmmount)
            slowMotion.run(SKAction.resize(toWidth: CGFloat(slowAmmount), duration: 0.1))
    }
    @objc func enemyImpulse(){
        let dx = CGFloat(arc4random_uniform(200))-100
        let dy = CGFloat(arc4random_uniform(200))-100
        enemy.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        //print("impulse to: x - \(dx) Y - \(dy) ")
        
    }
    @objc func countDown(){
        countTime.isHidden = false
        countTime.alpha = 1
        print(Counter)
        if Counter >= 1 {
            if Counter <= 1 {
                countTime.alpha = 1
                countTime.text = String("Dodge!")
                ball.physicsBody?.pinned = false
                enemy.physicsBody?.pinned = false
                Counter -= 1
            } else{
                 self.physicsWorld.speed = 2
            Counter -= 1
                countTime.alpha = 1
                countTime.text = String(Counter)
            }
        } else {
            gameTimer.invalidate()
            countTime.isHidden = true
            self.physicsWorld.speed = 2
            enemy.physicsBody?.applyAngularImpulse((CGFloat(arc4random_uniform(2))+1)/20)
        }
    }
     func coinCollected(){
        countTime.removeAllActions()
        countTime.alpha = 1
        score += 1
        print(score)
        countTime.text = String(score)
        countTime.isHidden = false
        countTime.alpha = 1
        countTime.run(SKAction.fadeOut(withDuration: 1.5))
      
        updateCoinPosition()
    
        }
    
    
    
     @objc func updateCoinPosition(){ //set new coin position by choosing random position repeatedly until its not close to the ball
        repeat{
        randomPosition = CGPoint( x:CGFloat( arc4random_uniform( UInt32( floor( frame.width ) ) ) ) - frame.width/2 ,
                                  y:(CGFloat( arc4random_uniform( UInt32( floor( frame.height - 300) ) ) ) - frame.height/2 ) + 300
        )
            
        } while ( (randomPosition.x > (ball.position.x - 200) && randomPosition.x < (ball.position.x + 200) ) && (randomPosition.y > (ball.position.y - 200) && randomPosition.y < (ball.position.y + 200) ) )
        

        coin.run(SKAction.move(to: randomPosition, duration: 0))
        coin.physicsBody?.contactTestBitMask = 00000001
        
        
        }
    
    @objc func gameEnd(){
        if score > highscore { //if new high score, set it in UserDefaults
            highscore = score
        UserDefaults.standard.set(highscore, forKey: "highscore")
        }
        slowMotion.run(SKAction.resize(toWidth: self.size.width, height: 330, duration: 0.2))
        slowMotion.run(SKAction.move(by: CGVector(dx: 0, dy: -40), duration: 0.2))
        
        
        menuLabel.isHidden = false
        highscoreLabel.text = "High Score: " + String(highscore)
        highscoreLabel.isHidden = false
        tryAgain.alpha = 0
        tryAgain.isHidden = false
        tryAgain.run(SKAction.fadeIn(withDuration: 1.5))
        gameOver = true
        
        
        }
    }


