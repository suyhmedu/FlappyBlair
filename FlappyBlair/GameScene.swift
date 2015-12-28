//
//  GameScene.swift
//  FlappyBlair
//
//  Created by Suyaib Ahmed on 12/14/15.
//  Copyright (c) 2015 MBHS Smartphone Programming Club. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Score variables
    var scoreLabelNode = SKLabelNode()
    var score = NSInteger()
    var moving:SKNode!
    var canRestart = false
    
    var skyColor:SKColor!
    
    var Ground = SKSpriteNode()
    var Blazer = SKSpriteNode()
    var towerPair = SKNode()
    var towers = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var Background = SKSpriteNode()
    
    //Blazer Animation
    var BlazerTextureAtlas = SKTextureAtlas()
    var BlazerArray = [SKTexture]()
    
    //Physics Category
    let categoryBlazer: UInt32 = 1 << 0
    let categoryGround: UInt32 = 1 << 1
    let categoryTower: UInt32 = 1 << 2
    let categoryScore: UInt32 = 1 << 3
    
    
    override func didMoveToView(view: SKView) {
        
        canRestart = false
        
        self.physicsWorld.contactDelegate = self
        
        moving = SKNode()
        self.addChild(moving)
        towers = SKNode()
        moving.addChild(towers)
        
        createTowers()
        
        //Background stuff
        
        // setup background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        Background = SKSpriteNode(imageNamed: "Background")
        Background.position = CGPoint(x: self.frame.width / 2, y: 0 + Background.frame.height / 2)
        Background.zPosition = 0
        self.addChild(Background)
        
        //Blazer(Bird) - Blazer Animation
        
        BlazerTextureAtlas = SKTextureAtlas(named: "Blazer")
        for i in 1...BlazerTextureAtlas.textureNames.count{
            let Name = "Devil_\(i).png"
            BlazerArray.append(SKTexture(imageNamed: Name))
        }
        
        //Blazer Animation
        Blazer = SKSpriteNode(imageNamed: BlazerTextureAtlas.textureNames[1])
        Blazer.size = CGSize(width:60, height: 35)
        Blazer.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        Blazer.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(BlazerArray, timePerFrame: 0.1)))
        
        Blazer.physicsBody = SKPhysicsBody(rectangleOfSize: Blazer.size)
        Blazer.physicsBody?.categoryBitMask = categoryBlazer
        Blazer.physicsBody?.collisionBitMask = categoryGround | categoryTower
        Blazer.physicsBody?.contactTestBitMask = categoryGround | categoryTower
        Blazer.physicsBody?.affectedByGravity = false
        Blazer.physicsBody?.dynamic = true
        Blazer.physicsBody?.allowsRotation = false
        Blazer.zPosition = 2
        self.addChild(Blazer)
        
        //Gound Image Layout
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(1.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = categoryGround
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"Chalkduster")
        scoreLabelNode.fontSize = 100
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 6 * self.frame.size.height / 7 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = "\(score)"
        self.addChild(scoreLabelNode)
        
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //What makes the Blazer jump with the touch
        if(gameStarted == false){
            gameStarted = true
            Blazer.physicsBody?.affectedByGravity = true
            let spawn = SKAction.runBlock({
                () in
                self.createTowers()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + towers.frame.width)
            let movePipes = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Blazer.physicsBody?.velocity = CGVectorMake(0,0)
            Blazer.physicsBody?.applyImpulse(CGVectorMake(0,30))
            
        }else {
            Blazer.physicsBody?.velocity = CGVectorMake(0,0)
            Blazer.physicsBody?.applyImpulse(CGVectorMake(0,30))
        }
        
        if canRestart {
            self.resetScene()
        }
        
    }
    func resetScene (){
        // Move bird to original position and reset velocity
        Blazer.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        Blazer.physicsBody?.collisionBitMask = categoryGround | categoryTower
        Blazer.zRotation = 0.0
        Blazer.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        Blazer.speed = 1.0
        
        // Remove all existing towers
        towers.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        
        // Reset score
        score = 0
        scoreLabelNode.text = "\(score)"
        
        // Restart animation
        moving.speed = 1
    }
    
    func createTowers(){
        towerPair = SKNode()
        let topTower = SKSpriteNode(imageNamed: "Tower")
        let btmTower = SKSpriteNode(imageNamed: "Tower")
        
        topTower.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + 340)
        btmTower.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 - 340)
        
        topTower.setScale(0.5)
        btmTower.setScale(0.5)
        
        topTower.physicsBody = SKPhysicsBody(rectangleOfSize: topTower.size)
        topTower.physicsBody?.categoryBitMask = categoryTower
        topTower.physicsBody?.collisionBitMask = categoryBlazer
        topTower.physicsBody?.contactTestBitMask = categoryBlazer
        topTower.physicsBody?.dynamic = false
        topTower.physicsBody?.affectedByGravity = false
        
        btmTower.physicsBody = SKPhysicsBody(rectangleOfSize: btmTower.size)
        btmTower.physicsBody?.categoryBitMask = categoryTower
        btmTower.physicsBody?.collisionBitMask = categoryBlazer
        btmTower.physicsBody?.contactTestBitMask = categoryBlazer
        btmTower.physicsBody?.dynamic = false
        btmTower.physicsBody?.affectedByGravity = false
        
        topTower.zRotation = CGFloat(M_PI)
        
        towerPair.addChild(topTower)
        towerPair.addChild(btmTower)
        
        towerPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        towerPair.position.y = towerPair.position.y + randomPosition
        
        let contactNode = SKNode()
        contactNode.position = CGPoint( x: topTower.size.width + Blazer.size.width / 2, y: self.frame.midY )
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize( width: topTower.size.width, height: self.frame.size.height ))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = categoryScore
        contactNode.physicsBody?.contactTestBitMask = categoryBlazer
        towerPair.addChild(contactNode)
        
        towerPair.runAction(moveAndRemove)
        towers.addChild(towerPair)
        
    }
    
    
    // Velocity of Blazer going up and down
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        Blazer.zRotation = self.clamp( -1, max: 0.5, value: Blazer.physicsBody!.velocity.dy * ( Blazer.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
    }
    func didBeginContact(contact: SKPhysicsContact){
        if (moving.speed > 0) {
            if( ( contact.bodyA.categoryBitMask & categoryScore ) == categoryScore || ( contact.bodyB.categoryBitMask & categoryScore ) == categoryScore ) {
                
                score++;
                scoreLabelNode.text = "\(score)"
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.runAction(SKAction.sequence([
                    SKAction.scaleTo(2.0, duration:NSTimeInterval(0.1)),
                    SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))
                    ]))
                
            } else {
    
                moving.speed = 0
                
                Blazer.physicsBody?.collisionBitMask = categoryGround
                
                //Flash background if contact is detected
                self.removeActionForKey("flash")
                self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
                    self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                }),SKAction.waitForDuration(NSTimeInterval(0.05)), SKAction.runBlock({
                    self.backgroundColor = self.skyColor
                }), SKAction.waitForDuration(NSTimeInterval(0.05))]), count:4), SKAction.runBlock({
                    self.canRestart = true
                })]), withKey: "flash")
                
            }
        }
    }
}

