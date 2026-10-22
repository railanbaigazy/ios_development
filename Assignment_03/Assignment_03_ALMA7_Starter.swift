// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================
    
// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let reading = splitOnce(raw, by: ":"),
          let value = Int(reading.1),
          !reading.0.isEmpty,
          value >= 0 || reading.0 == "TEMP"
          else { return nil }
    
    return (sensor: reading.0, value)
}

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    
    return (valid, invalidCount)
}

let A = parseLog(rawLog).invalidCount

print("\n*** TASK 1 ***\n")
print(parseLog(["O2:87", "TEMP:-12", "RAD:-1", ":55"]))

// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var filteredReadings: [Reading] = []
    
    for reading in readings {
        if isIncluded(reading) {
            filteredReadings.append(reading)
        }
    }
    
    return filteredReadings
}

func values(of readings: [Reading]) -> [Int] {
    var values: [Int] = []
    
    for reading in readings {
        values.append(reading.value)
    }
    
    return values
}

let o2Readings = select(parseLog(rawLog).valid) { $0.sensor == "O2" }

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    if values.isEmpty {
        return nil
    }
    
    var sum = 0
    var currentMin = Int.max
    var currentMax = Int.min
    
    for value in values {
        sum += value
        currentMin = min(value, currentMin)
        currentMax = max(value, currentMax)
    }
    
    return (currentMin, currentMax, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("\n*** TASK 2.2 ***\n")
print(stats(1, 2, 3, 0))
print(stats())

let B = Int(stats(of: values(of: o2Readings))?.average ?? 0)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
// 1. Full closure syntax with types and return
let sort1 = o2Readings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

// 2. Types inferred from context
let sort2 = o2Readings.sorted(by: {(a, b) in
    return a.value > b.value
})

// 3. Implicit return
let sort3 = o2Readings.sorted(by: { (a, b) in
    a.value > b.value
})

// 4. Shorthand arguments
let sort4 = o2Readings.sorted(by: { $0.value > $1.value })

// 5. Trailing closure
let sort5 = o2Readings.sorted { $0.value > $1.value }

func sameResult(_ a: [Reading], _ b: [Reading]) -> Bool {
    if a.count != b.count { return false}
    
    for i in 0..<a.count {
        if a[i] != b[i] { return false }
    }
    
    return true
}

print("All sorts match:",
      sameResult(sort1, sort2) &&
      sameResult(sort2, sort3) &&
      sameResult(sort3, sort4) &&
      sameResult(sort4, sort5)
)

// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    }
    
    if temp > 24 {
        return coolDown
    }
    
    return hold
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var steps = 0
    var currentTemp = start
    
    while (currentTemp < 18 || currentTemp > 24) && steps < maxSteps {
        currentTemp = chooseProtocol(for: currentTemp)(currentTemp)
        steps += 1
    }
    
    
    return (finalTemp: currentTemp, steps, isStable: currentTemp >= 18 && currentTemp <= 24)
    
}

let tempReadings = select(parseLog(rawLog).valid) { $0.sensor == "TEMP" }
let C = runUntilStable(from: stats(of: values(of: tempReadings))?.min ?? 0).steps

print("\n*** TASK 3 ***\n")
print("runUntilStable from 31:", runUntilStable(from: 31))
print("runUntilStable from 18:", runUntilStable(from: 18))
print("runUntilStable from -100 with maxSteps 5:", runUntilStable(from: -100, maxSteps: 5))
print("C:", C)

// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let module = member.module?.name ?? "open space"
        
        return "\(member.name): no data (\(module))"
        
    }
    
    return "\(member.name): \(level)% \(level < 20 ? "CRITICAL" : "OK")"
}

print("\n*** TASK 4 ***\n")
print("Members statuses:")
for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    
    let transferredAmount = min(amount, source, 100 - target)
    source -= transferredAmount
    target += transferredAmount
    
    return transferredAmount
}

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
}

let D = hab.oxygenTank?.level ?? 0

print("D:", D)

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var members: [CrewMember] = []
    var orderedNames: [String] = []
    
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member:", name)
            continue
        }
        
        members.append(member)
    }
    
    members.sort { $0.priority < $1.priority }
    
    for member in members {
        orderedNames.append(member.name)
    }
    
    return orderedNames
}

print("\nMembers evacuation order:")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank! // There should be guards, because both module and oxygenTank are optional
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String { // Must return String?
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 { // nil oxygenLevel will fail
            result = member.name // Changes result with every <20 step, so it makes the function lastCritical
        }
    }
    return result! // It is the default case when not found, so should be nil
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no data"
    }
    
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            print("no data for member:", member.name)
            continue
        }
        
        if level < 20 { return member.name }
    }
    
    return nil
}

let testModule1 = Module(name: "Module 1", oxygenTank: Tank(level: 15))
let testModule2 = Module(name: "Module 2", oxygenTank: Tank(level: 5))
let testModule3 = Module(name: "Module 2", oxygenTank: Tank(level: 20))
let memberA = CrewMember(name: "Member A", role: "Test", priority: 1, module: testModule1)
let memberB = CrewMember(name: "Member B", role: "Test", priority: 2, module: testModule2)
let memberC = CrewMember(name: "Member C", role: "Test", priority: 3, module: testModule3)
let noDataMember = CrewMember(name: "NoData Member", role: "Test", priority: 0, module: nil)

print("\n*** TASK 5 ***\n")
let testPassed = firstCritical(in: [memberB, memberA]) ?? "nil" == "Member B"
    && firstCritical(in: [memberA, memberB]) ?? "nil" == "Member A"
    && firstCritical(in: [noDataMember, memberA]) ?? "nil" == "Member A"
    && firstCritical(in: [memberC]) ?? "nil" == "nil"

print("Test passed:", testPassed)

// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var alarmCount = 0
    
    return { level in
        let fired = level < threshold
        
        if fired {
            alarmCount += 1
            print("Alarm #\(alarmCount)")
        }
        
        return fired
    }
}

print("\n*** BONUS TASK ***\n")
let alarm = makeAlarm(threshold: 20)

print(alarm(12))
print(alarm(40))
print(alarm(5))

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
 
 if let keeps the variable available only inside its block, doesn't require an exit
 
 guard let keeps the variable available for the rest of the scope (except else block), requires else block
 that exits the scope

 2. Why can't you pass [Int] to stats(_ values: Int...)?
 
 Because this stats function requires values to be a comma separated arguments, since it is type noted as variadic
 parameter

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
 
 Because inout source and target should be different, since exclusive access to memory blocks block the simultaneous
 read or write access to the same alias

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
 
 Because oxygenLevel returns type Int?, but "no data" is string, so Int? ?? String doesn't typecheck

 5. Full type of chooseProtocol and how to read it:
 
 (Int) -> (Int) -> Int
 
 chooseProtocal is a dispatcher function that takes an Int and returns a function,
 which takes an Int and returns an Int.

 Bonus. Where does the alarm counter live after makeAlarm returns?

 makeAlarm holds a reference to the alarmCount and threshold heap boxes in its context
 that is why they can be accessed later as a closure that captured variables
 from its surrounding scope
*/
