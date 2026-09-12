import UIKit

// Easy tasks
// 1.
let fruits = ["Apple", "Banana", "Pear", "Pineapple", "Melon"]

print(fruits[2])

// 2.
var favoriteNumbers: Set<Int> = [1, 2, 4, 5]

favoriteNumbers.insert(6)
print(favoriteNumbers)

// 3.
let programmingLanguages: [String: Int] = ["JS": 1995, "Java": 1995, "Swift": 2014]

print(programmingLanguages["Swift"])

// 4.
var colors = ["White", "Yellow", "Red", "Green"]

colors[1] = "Cyan"
print(colors)

// Medium tasks
// 1.
let set1: Set<Int> = [1, 2, 3, 4]
let set2: Set<Int> = [3, 4, 5, 6]

let twoSetIntersection = set1.intersection(set2)

print(twoSetIntersection)

// 2.
var studentScores: [String: Int] = ["Abzal": 99, "Zhanserik": 89, "Bolat": 67, "John": 98]
studentScores["Zhanserik"] = 67

print(studentScores)

// 3.
let arr1 = ["apple", "banana"]
let arr2 = ["cherry", "date"]

let mergedArr = arr1 + arr2
print(mergedArr)

// Hard tasks
// 1.
var countriesPopulation: [String: Int] = ["Kazakhstan": 20_000_000, "India": 1_200_000_000, "Portugal": 60_000_000]

countriesPopulation["Uzbekistan"] = 50_000_000
print(countriesPopulation)

// 2.
let animalsSet1: Set<String> = ["cat", "dog"]
let animalsSet2: Set<String> = ["dog", "mouse"]

let unionSubtractSet = animalsSet1.union(animalsSet2).subtracting(animalsSet2)
print(unionSubtractSet)

// 3.
let studentGrades: [String: [Int]] = [
    "Arman": [99, 89, 100],
    "Zhan": [45, 67, 88],
    "Tom": [74, 78, 86]
]

print(studentGrades["Arman"]?[1])
