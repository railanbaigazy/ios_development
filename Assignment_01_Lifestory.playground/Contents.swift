import UIKit

// Step 1
let currentYear = 2026

var firstName = "Railan"
var secondName = "Baigazy"
var birthYear = 2004
var isStudent = true
var height = 1.91

let age = currentYear - birthYear

// Step 2
var hobby = "playing drums"
var numberOfHobbies = 4
var favoriteNumber = 1
var isHobbyCreative = true

var currentJob = "software engineer in fintech"
var futureGoals = "learn iOS development to run my apps in App Store to hustle"

// Step 3
let lifeStory = """
My name is \(firstName) \(secondName). I am \(age) years old, born in \(birthYear). I am \(height) meters tall.
I am currently \(isStudent ? "" : "not") a student. 
I love \(hobby), which is \(isHobbyCreative ? "" : "not") a creative hobby.
I have \(numberOfHobbies) hobbies in total and my favorite number is \(favoriteNumber).
My current job is a \(currentJob) and I want to \(futureGoals)
"""

// Step 4
print(lifeStory)
