//
//  GameScene.swift
//  Splatter
//
//  Created by Thomas Perritt on 07/05/2019.
//  Copyright © 2019 Thomas Perritt. All rights reserved.
//

import SpriteKit
import CoreMotion

struct PhysicsCategory {
    
    static let Paintballs : UInt32 = 1 << 1
    static let Scoreballs : UInt32 = 1 << 2
    static let Character : UInt32 = 1 << 3
    static let Ground : UInt32 = 1 << 4
    static let none : UInt32 = 0
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var allImageNames = ["Paintballs_Red", "Paintballs_Orange", "Paintballs_Green", "Paintballs_Yellow", "Paintballs_Blue"]
    var allGroundNames = ["Ground_Red", "Ground_Orange", "Ground_Green", "Ground_Yellow", "Ground_Blue"]
    var allCharacterNames = ["Painting_Red", "Painting_Orange", "Painting_Green", "Painting_Yellow", "Painting_Blue"]
    var allGroundSplatNames = ["Splat_Red", "Splat_Orange", "Splat_Green", "Splat_Yellow", "Splat_Blue"]
    
    var paintballImageNames = [String]()
    var splatImageNames = [String]()
    var scoreballImageName = [String]()
    var scoreballGroundColour = [String]()
    var scoreballCharacterColour = [String]()
    
    var gameOngoing = Bool()
    var lockTapAnywhere = Bool()
    
    var currentScore: Int = 0
    var highScore: Int = 0
    
    let currentScoreLbl = SKLabelNode()
    let highScoreLbl = SKLabelNode()
    let tapToStartLbl = SKLabelNode()
    let howToPlayLbl = SKLabelNode()
    
    let manager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var appLogo = SKSpriteNode(imageNamed: "Splatter Image")

    var restartGameButton = SKSpriteNode()
    var characterLegsLeft = SKSpriteNode()
    var characterLegsRight = SKSpriteNode()
    var characterBody = SKSpriteNode()
    var ground = SKSpriteNode()
    var topBanner = SKSpriteNode()
    var backgroundImage = SKSpriteNode()
    
    // Game Difficulty
    var velocity = CGFloat.random(min: 1, max: 1.7)
    var spawnRate = 0.8
    
    var lastAdDisplayedCounter = 0
    
    override func didMove(to view: SKView) {
        
        createScene()
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }
    
    func createScene(){
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.current!){
            (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.35
            }
        }
        
        gameOngoing = false
        lockTapAnywhere = false
        currentScore = 0

        for i in 0..<2{
            
            topBanner = SKSpriteNode(imageNamed: "Coloured Top Banner")
            topBanner.name = "topBanner"
            topBanner.size = CGSize(width: (self.frame.width / 5) * 10, height: self.frame.width / 5)
            topBanner.anchorPoint = CGPoint.zero
            topBanner.position = CGPoint(x: CGFloat(i) * topBanner.frame.size.width, y: (self.frame.size.height - self.topBanner.size.height))
            
            addChild(topBanner)
            topBanner.zPosition = 2
            
            backgroundImage = SKSpriteNode(imageNamed: "Background Image")
            backgroundImage.name = "backgroundImage"
            backgroundImage.size = CGSize(width: self.frame.width, height: self.frame.height * 2)
            backgroundImage.anchorPoint = CGPoint.zero
            backgroundImage.position = CGPoint(x: 0, y: CGFloat(i) * self.backgroundImage.size.height)
            
            addChild(backgroundImage)
            backgroundImage.zPosition = -1
        }
        
        let HighscoreDefault = UserDefaults.standard
        if (HighscoreDefault.value(forKey: "Highscore") != nil){
            highScore = HighscoreDefault.value(forKey: "Highscore") as! NSInteger
        }
        
        highScoreLbl.name = "highScoreLbl"
        highScoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 30)
        highScoreLbl.text = "Best: \(highScore)"
        highScoreLbl.fontName = "YatraOne-Regular"
        highScoreLbl.fontSize = 20
        highScoreLbl.zPosition = 3
        
        self.addChild(highScoreLbl)
        
        tapToStartLbl.position = CGPoint(x: (self.view?.bounds.width)! / 2, y: self.frame.height / 4.6)
        tapToStartLbl.fontSize = (self.view?.bounds.width)! / 14
        tapToStartLbl.text = "Tap to Start"
        tapToStartLbl.fontName = "YatraOne-Regular"
        tapToStartLbl.alpha = 0.9
        tapToStartLbl.zPosition = 2
        
        howToPlayLbl.position = CGPoint(x: (self.view?.bounds.width)! / 2, y: self.frame.height / 2.7)
        howToPlayLbl.fontSize = (self.view?.bounds.width)! / 25
        howToPlayLbl.text = "Catch the Matching Drops!"
        howToPlayLbl.fontName = "YatraOne-Regular"
        howToPlayLbl.fontColor = UIColor.black
        howToPlayLbl.alpha = 0.6
        howToPlayLbl.zPosition = 2
        
        bounceAnimation()
        
        appLogo.size  = CGSize(width: self.frame.width / 2 + (view!.frame.width / 4) , height: ((self.frame.width / 13) * 5))
        appLogo.position = CGPoint(x: (self.view?.bounds.width)! / 2, y: (self.frame.height / 2))
        
        appLogo.zPosition = 2
        self.addChild(appLogo)
        
    }
    
    func bounceAnimation(){
        self.addChild(tapToStartLbl)
        self.addChild(howToPlayLbl)
        tapToStartLbl.run(SKAction.sequence([
                SKAction.scale(by: 0.8, duration: 1),
                SKAction.scale(by: 1.25, duration: 1)]))
    }
    
    func restartScene(){
        
        self.removeAllActions()
 
        for child in children{
            if child.name == topBanner.name {
            }
            else if child.name == backgroundImage.name {
            }
            else if child.name == highScoreLbl.name {
            }
            else{
                child.removeFromParent()
            }
        }
    
        scoreballImageName.removeAll()
        paintballImageNames.removeAll()
        splatImageNames.removeAll()
        scoreballGroundColour.removeAll()
        scoreballCharacterColour.removeAll()
        
        gameOngoing = false
        lockTapAnywhere = false
        currentScore = 0
        
        spawnRate = 0.8
        velocity = CGFloat.random(min: 1, max: 1.7)
        
        bounceAnimation()
        self.addChild(appLogo)
    
        if lastAdDisplayedCounter == 0 {
            lastAdDisplayedCounter += 1
        }
        else if lastAdDisplayedCounter == 1{
            let x = CGFloat.random(min: 0, max: 1)
            if x > 0.5{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowInterAdKey"), object: nil)
            }
            else {
                lastAdDisplayedCounter += 1
            }
        }
        else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowInterAdKey"), object: nil)
            lastAdDisplayedCounter = 0
        }
    }
    
    func endGame(){
        
        topBanner.removeAllActions()
        backgroundImage.removeAllActions()
        characterLegsLeft.removeAllActions()
        characterLegsRight.removeAllActions()
        for child in self.children {
            if child.hasActions() == true && child != characterLegsLeft && child != characterLegsRight {
                child.removeAllActions()
                child.removeFromParent()
            }
        }
        
        self.removeAllActions()
        gameOngoing = false
        
        restartGameButton = SKSpriteNode(imageNamed: "Restart Image")
        restartGameButton.size = CGSize(width: (view!.frame.width / 1.7), height: (view!.frame.width / 3.4))
        restartGameButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartGameButton.setScale(0)
        
        self.addChild(restartGameButton)
        restartGameButton.run(SKAction.scale(to: 1.0, duration: 0.4))
    }
    
    func createGameScene(){
        
        gameOngoing = true
        lockTapAnywhere = true
        tapToStartLbl.removeFromParent()
        howToPlayLbl.removeFromParent()
        appLogo.removeFromParent()
       
        // let randomNum = Int(round(CGFloat.random(min: 0.55, max: 5.45))) - 1
        let randomNum = Int.random(min: 0, max: 4)
        scoreballImageName.append(allImageNames[randomNum])
        scoreballGroundColour.append(allGroundNames[randomNum])
        scoreballCharacterColour.append(allCharacterNames[randomNum])
  
        for i in 0...(allImageNames.count - 1){
            if i != randomNum{
                paintballImageNames.append(allImageNames[i])
                splatImageNames.append(allGroundSplatNames[i])
            }
        }
        
        currentScoreLbl.name = "currentScoreLbl"
        currentScoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 4)
        currentScoreLbl.text = "\(currentScore)"
        currentScoreLbl.fontName = "YatraOne-Regular"
        currentScoreLbl.fontSize = 50
        currentScoreLbl.zPosition = 3
        
        self.addChild(currentScoreLbl)
        
        var imageString = scoreballGroundColour[0]
        ground = SKSpriteNode(imageNamed:"\(imageString)")

        ground.size = CGSize(width: self.frame.width, height: self.frame.width / 5)
        ground.position = CGPoint(x: self.frame.width / 2, y: ((self.frame.height / 7) - ground.frame.height))
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Paintballs | PhysicsCategory.Scoreballs
        ground.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        ground.physicsBody?.isDynamic = false
        self.addChild(ground)
        
        imageString = scoreballCharacterColour[0]
        
        characterBody = SKSpriteNode(imageNamed:"\(imageString)")
        characterBody.size  = CGSize(width: self.frame.width / 4 , height: characterBody.frame.width / 2)
        characterBody.position = CGPoint(x: self.frame.width / 2, y: ground.frame.maxY + characterBody.frame.height / 2)
        characterBody.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: characterBody.frame.width, height: characterBody.frame.height / 2))
        
        characterBody.physicsBody?.categoryBitMask = PhysicsCategory.Character
        characterBody.physicsBody?.contactTestBitMask = PhysicsCategory.Paintballs | PhysicsCategory.Scoreballs
        characterBody.physicsBody?.collisionBitMask = PhysicsCategory.none
        characterBody.physicsBody?.isDynamic = true
        
        characterLegsLeft = SKSpriteNode(imageNamed: "Running 45 Anti")
        characterLegsLeft.size  = CGSize(width: characterBody.size.width / 3 , height: characterBody.size.width / 3)
        characterLegsLeft.position = CGPoint(x: self.frame.width / 2 - characterBody.size.width, y: ground.frame.maxY + ((characterBody.frame.height / 10) * 7))
        
        characterLegsRight = SKSpriteNode(imageNamed: "Running 45")
        characterLegsRight.size  = CGSize(width: characterBody.size.width / 3 , height: characterBody.size.width / 3)
        characterLegsRight.position = CGPoint(x: self.frame.width / 2 - characterBody.size.width, y: ground.frame.maxY + ((characterBody.frame.height / 10) * 7))
        
        characterBody.zPosition = 1
        characterLegsLeft.zPosition = 2
        characterLegsRight.zPosition = 2
        
        self.addChild(characterBody)
        self.addChild(characterLegsLeft)
        self.addChild(characterLegsRight)
 
        
        let delayUpdate = 0.03
        self.run(SKAction.repeatForever(
            // Rotate the Character's Legs
            SKAction.sequence([
                SKAction.run(self.rotateWheels),
                SKAction.wait(forDuration: delayUpdate)
                ])
        ))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Spawn Paintballs and Scoreballs
            self.run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(self.whichTypeOfBall),
                    SKAction.wait(forDuration: self.spawnRate)
                    ])
            ))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if gameOngoing == false && lockTapAnywhere == false{
                createGameScene()
            }
            else if gameOngoing == false && restartGameButton.contains(location){
                restartScene()
            }
        }
    }

    func whichTypeOfBall(){
        
        // let randomCounter = Int(round(CGFloat.random(min: 0.5, max: 3.4))) - 1
        let randomCounter = Int.random(min: 0, max: 3)
        
        if randomCounter == 0 {
            addScoreball()
        }
        else {
            addPaintball()
        }
    }
    
    func addPaintball() {
        
        let PaintballSize = self.frame.height / 24
        // let randomColour = Int(round(CGFloat.random(min: 0.5, max: 4.4))) - 1
        let randomColour = Int.random(min: 0, max: 3)
        let imageString = paintballImageNames[randomColour]
        
        // Create Sprite
        let paintballObject = SKSpriteNode(imageNamed:"\(imageString)")
        paintballObject.size = CGSize(width: PaintballSize, height: PaintballSize)
        paintballObject.physicsBody = SKPhysicsBody(rectangleOf: paintballObject.size)
        paintballObject.physicsBody?.isDynamic = true
        paintballObject.physicsBody?.categoryBitMask = PhysicsCategory.Paintballs
        paintballObject.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Character
        paintballObject.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let actualX = CGFloat.random(min: paintballObject.size.width, max: size.width - paintballObject.size.width)
        paintballObject.position = CGPoint(x: actualX, y: size.height + paintballObject.size.height)
        
        addChild(paintballObject)

        let actionDrop = SKAction.move(to: CGPoint(x: actualX, y: -paintballObject.size.height), duration: TimeInterval(velocity))
        let actionDropDone = SKAction.removeFromParent()
        
        paintballObject.run(SKAction.sequence([actionDrop, actionDropDone]))
        
    }
    
    func addScoreball() {
        
        let ScoreballSize = self.frame.height / 24
        let imageString = scoreballImageName[0]
        
        // Create Sprite
        let scoreballObject = SKSpriteNode(imageNamed:"\(imageString)")
        scoreballObject.size = CGSize(width: ScoreballSize, height: ScoreballSize)
        scoreballObject.physicsBody = SKPhysicsBody(rectangleOf: scoreballObject.size)
        scoreballObject.physicsBody?.isDynamic = true
        scoreballObject.physicsBody?.categoryBitMask = PhysicsCategory.Scoreballs
        scoreballObject.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Character
        scoreballObject.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let actualX = CGFloat.random(min: scoreballObject.size.width, max: size.width - scoreballObject.size.width)
        scoreballObject.position = CGPoint(x: actualX, y: size.height + scoreballObject.size.height)
        
        addChild(scoreballObject)
        
        let actionDrop = SKAction.move(to: CGPoint(x: actualX, y: -scoreballObject.size.height), duration: TimeInterval(velocity))
        let actionDropDone = SKAction.removeFromParent()
        
        scoreballObject.run(SKAction.sequence([actionDrop, actionDropDone]))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        /* The larger number (below) is the secondBody
        Painballs : UInt32 = 1 << 1
        Scoreballs : UInt32 = 1 << 2
        Character : UInt32 = 1 << 3
        Ground : UInt32 = 1 << 4 */
        
        if firstBody.categoryBitMask == PhysicsCategory.Paintballs &&
            secondBody.categoryBitMask == PhysicsCategory.Ground {

            if let paintball = firstBody.node as? SKSpriteNode,
                let ground = secondBody.node as? SKSpriteNode {
                paintballDidCollideWithGround(paintball: paintball, ground: ground)
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Scoreballs &&
            secondBody.categoryBitMask == PhysicsCategory.Ground {
            
            if let scoreball = firstBody.node as? SKSpriteNode,
                let ground = secondBody.node as? SKSpriteNode {
                scoreballDidCollideWithGround(scoreball: scoreball, ground: ground)
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Paintballs &&
            secondBody.categoryBitMask == PhysicsCategory.Character {
            
            if let paintball = firstBody.node as? SKSpriteNode,
                let character = secondBody.node as? SKSpriteNode {
                paintballDidCollideWithCharacter(paintball: paintball, character: character)
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Scoreballs &&
            secondBody.categoryBitMask == PhysicsCategory.Character {
            
            if let scoreball = firstBody.node as? SKSpriteNode,
                let character = secondBody.node as? SKSpriteNode {
                scoreballDidCollideWithCharacter(scoreball: scoreball, character: character)
            }
        }

    }

    func paintballDidCollideWithGround(paintball: SKSpriteNode, ground: SKSpriteNode) {
        
        var whichColour = 0
        let xPosition = paintball.position.x
        let paintballDescription = String(paintball.texture!.description)
        
        if paintballDescription.contains("Orange"){
            for i in 0...splatImageNames.count - 1{
                if splatImageNames[i].contains("Orange") {
                    whichColour = i
                }
            }
        }
        else if paintballDescription.contains("Red"){
            for i in 0...splatImageNames.count - 1{
                if splatImageNames[i].contains("Red") {
                    whichColour = i
                }
            }
        }
        else if paintballDescription.contains("Blue"){
            for i in 0...splatImageNames.count - 1{
                if splatImageNames[i].contains("Blue") {
                    whichColour = i
                }
            }
        }
        else if paintballDescription.contains("Green"){
            for i in 0...splatImageNames.count - 1{
                if splatImageNames[i].contains("Green") {
                    whichColour = i
                }
            }
        }
        else if paintballDescription.contains("Yellow"){
            for i in 0...splatImageNames.count - 1{
                if splatImageNames[i].contains("Yellow") {
                    whichColour = i
                }
            }
        }
        createSplat(colour: whichColour, position: xPosition)
        paintball.removeFromParent()
        ground.position = CGPoint(x: self.frame.width / 2, y: ((self.frame.height / 7) - ground.frame.height))
    }
    
    func paintballDidCollideWithCharacter(paintball: SKSpriteNode, character: SKSpriteNode) {
        
        paintball.removeFromParent()
        characterBody.position = CGPoint(x: characterBody.position.y, y: ground.frame.maxY + characterBody.frame.height / 2)
        endGame()
    }
    
    func scoreballDidCollideWithCharacter(scoreball: SKSpriteNode, character: SKSpriteNode) {
        
        scoreball.removeFromParent()
        characterBody.position = CGPoint(x: characterBody.position.y, y: ground.frame.maxY + characterBody.frame.height / 2)
        addScore()
    }
    
    func scoreballDidCollideWithGround(scoreball: SKSpriteNode, ground: SKSpriteNode) {
        
        scoreball.removeFromParent()
        ground.position = CGPoint(x: self.frame.width / 2, y: ((self.frame.height / 7) - ground.frame.height))
        endGame()
    }
    
    func addScore(){
        
        currentScore += 1
        currentScoreLbl.text = "\(currentScore)"
        
        if highScore < currentScore {
            highScore = currentScore
            highScoreLbl.text = "Best: \(currentScore)"
            
            let HighscoreDefault = UserDefaults.standard
            HighscoreDefault.setValue(highScore, forKey: "Highscore")
            HighscoreDefault.synchronize()
        }
    }
    
    func createSplat(colour: Int, position: CGFloat){
        
        let splatSize = self.frame.height / 24
        let imageString = splatImageNames[colour]
        
        let splat = SKSpriteNode(imageNamed:"\(imageString)")
        splat.size = CGSize(width: splatSize, height: splatSize)
        splat.position = CGPoint(x: position, y: ground.frame.maxY - (splatSize / 2))
        splat.zPosition = 2
        
        self.addChild(splat)
        
        let actionFade = SKAction.fadeOut(withDuration: 0.3)
        let actionFadeDone = SKAction.removeFromParent()
        splat.run(SKAction.sequence([actionFade, actionFadeDone]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameOngoing == true {
            moveBanner()
            moveBackground()
            updateDifficulty()
        }
    }
    
    func updateDifficulty(){
        
        if currentScore > 100{
            spawnRate = 0.2
            velocity = CGFloat.random(min: 0.4, max: 0.8)
        }
        else if currentScore > 75{
            spawnRate = 0.25
            velocity = CGFloat.random(min: 0.4, max: 0.9)
        }
        else if currentScore > 50{
            spawnRate = 0.3
            velocity = CGFloat.random(min: 0.5, max: 1)
        }
        else if currentScore > 40{
            spawnRate = 035
            velocity = CGFloat.random(min: 0.5, max: 1.4)
        }
        else if currentScore > 30{
            spawnRate = 0.35
            velocity = CGFloat.random(min: 0.6, max: 1.5)
        }
        else if currentScore > 23{
            spawnRate = 0.4
            velocity = CGFloat.random(min: 0.7, max: 1.5)
        }
        else if currentScore > 18{
            spawnRate = 0.5
            velocity = CGFloat.random(min: 0.8, max: 1.5)
        }
        else if currentScore > 12{
            spawnRate = 0.55
            velocity = CGFloat.random(min: 0.9, max: 1.5)
        }
        else if currentScore > 8{
            spawnRate = 0.60
            velocity = CGFloat.random(min: 0.9, max: 1.6)
        }
        else if currentScore > 6{
            spawnRate = 0.6
            velocity = CGFloat.random(min: 1, max: 1.6)
        }
        else if currentScore > 4{
            spawnRate = 0.65
            velocity = CGFloat.random(min: 1, max: 1.63)
        }
        else if currentScore > 2{
            spawnRate = 0.7
            velocity = CGFloat.random(min: 1, max: 1.66)
        }
    }
    
    func moveBanner(){
        
        self.enumerateChildNodes(withName: "topBanner", using: ({
            (node, error) in
            let x = node as! SKSpriteNode
            x.position = CGPoint(x: x.position.x - 3, y: x.position.y)
            if x.position.x <= -x.size.width {
                x.position = CGPoint(x: x.position.x + x.size.width * 2, y: x.position.y)
            }
        }))
    }
    
    func moveBackground(){
        
        self.enumerateChildNodes(withName: "backgroundImage", using: ({
            (node, error) in
            let image = node as! SKSpriteNode
            image.position = CGPoint(x: image.position.x, y: image.position.y - 4)
            if image.position.y <= -image.size.height {
                image.position = CGPoint(x: image.position.x, y: image.position.y + image.size.height * 2)
            }
        }))
    }
    
    func rotateWheels(){
        
        let wheelRotationSpeed = self.xAcceleration * 200
        characterLegsLeft.run(SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi * wheelRotationSpeed, duration: 2)), withKey: "rotateWheel")
        characterLegsRight.run(SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi * wheelRotationSpeed, duration: 2)), withKey: "rotateWheel")
    }
    
    override func didSimulatePhysics() {
        
        characterBody.position.x += xAcceleration * 50
        
        if characterBody.position.x <= (0 - (characterBody.frame.width * 0.25)) {
            characterBody.position = CGPoint(x: 0 - (characterBody.frame.width * 0.25), y: characterBody.position.y)
        }
        else if characterBody.position.x > (self.frame.width + (characterBody.frame.width * 0.25)) {
            characterBody.position = CGPoint(x: self.frame.width + (characterBody.frame.width * 0.25), y: characterBody.position.y)
        }
        self.characterLegsLeft.position = CGPoint(x: characterBody.position.x - ((characterBody.size.width / 8) * 2.75), y: characterBody.position.y - (characterBody.size.height / 3) + (characterLegsLeft.size.height / 4))
        self.characterLegsRight.position = CGPoint(x: characterBody.position.x + ((characterBody.size.width / 8) * 2.75), y: characterBody.position.y - (characterBody.size.height / 3) + (characterLegsRight.size.height / 4))
    }
}
