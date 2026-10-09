// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Note on structure: the original starter wrapped everything in
//  `#Playground { ... }` (from `import Playgrounds`). That macro body
//  is a function/closure scope, and Swift does not allow `extension`
//  declarations inside a function scope — verified directly against
//  the installed toolchain (swift-driver 1.168.6 / Swift 6.4), which
//  reports "declaration is only valid at file scope" for every
//  `extension` nested in that block. Since Level 5 explicitly requires
//  `extension Diagnosable { ... }`, `extension LegacyBeacon: Diagnosable`,
//  and `extension Int { ... }`, the two are incompatible. This file uses
//  plain top-level script code instead — it runs the same way via
//  `swift ALMA7_Part3_Starter.swift` and pastes into a classic Xcode
//  Playground unchanged; only the macro wrapper is gone.
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here? -> A PowerCell is shared, mutable
// state: a Drone holds a reference to one cell, and every call site that
// spends or recharges it must see the same live value — value-type
// copying would let callers silently drift out of sync.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
let demoCell = PowerCell(charge: 50)
// demoCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> It locks the logic so no subclass
// can skip the charge check, reorder the steps, or fake success
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []

for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Skipping unknown drone kind \"\(record.kind)\" for record \(record.id).")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)

for drone in fleet {
    print(drone.statusLine)
}

var dronesReadyForAnotherTask = 0

for drone in fleet {
    if drone.cell.level() >= drone.powerCost {
        dronesReadyForAnotherTask += 1
    }
}

print("Drones still ready for one more task: \(dronesReadyForAnotherTask)")

var B = 0

for drone in fleet {
    B += drone.cell.level()
}

let C = dronesReadyForAnotherTask


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`? -> Drone is a class, a reference type
// so calling recharge(by:) mutates the shared PowerCell's instanace
// with a constant reference, not with Drone's own stored properties
// thus there is no value-type copy to protect
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { Drone.statusCode(for: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { SensorModule.statusCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []

for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// 4.3
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    
    for component in components {
        lines.append(component.diagnose())
    }
    
    return lines.joined(separator: "\n")
}

// Why could [Drone] never have held the sensors? -> SensorModule is a struct,
// not a subclass of Drone - hence [Drone] can only ever store Drone or its subclasses
var diagnosticsComponents: [Diagnosable] = []

for drone in fleet {
    diagnosticsComponents.append(drone)
}

for sensor in sensors {
    diagnosticsComponents.append(sensor)
}

print(diagnosticsReport(diagnosticsComponents))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    static func statusCode(for value: Int) -> Int {
        if value < 20 { return 2 }
        if value < 50 { return 1 }
        
        return 0
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { LegacyBeacon.statusCode(for: signalStrength) }

    func diagnose() -> String {
        "LEGACY HARDWARE — \(componentID): signal \(signalStrength)% (code \(statusCode))"
    }
}

diagnosticsComponents.append(beacon)
print(diagnosticsReport(diagnosticsComponents))

var D = 0

for component in diagnosticsComponents {
    D += component.statusCode
}

// 5.3
extension Int {
    var powerBar: String {
        var filled = self / 10
        
        if filled < 0 { filled = 0 }
        if filled > 10 { filled = 10 }
        
        var bar = ""
        
        for slot in 0..<10 {
            bar += slot < filled ? "#" : "."
        }
        
        return bar
    }
}


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}
// Expectation: PatchDrone overrides performTask() to always produce 30 work units
// Actual: doesn't compile - "overriding declaration requires an 'override' keyword",
// PatchDrone.performTask() has the exact same signature as Drone.performTask(),
//  so it is refused to let it shadow the superclass member
// Rule: any method/property/subscript that matches a non-final superclass member
//  must be explicitly marked `override`.
// Fix: write `override func performTask() -> Int { return 30 }`

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}
// Expectation: a stronger welder that always reports 999 work units
// Actual: doesn't compile, for two reasons -
// (a) WelderDrone is `final`, so inheritance from a final class 'WelderDrone' is illegal
// (b) even if it weren't, Drone.runOnce() is itself `final`, so
// instance method overrides a 'final' instance method is illegal too
// Rule: `final` on a class forbids subclassing it, `final` on a method forbids overriding it at any depth
// Fix: there's no way to preserve this - that's exactly what `final` is protecting.
// If different numbers are needed, subclass Drone directly and override
// `powerCost` / `performTask()`, leaving runOnce() alone

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())
// Expectation: `first` is a WelderDrone at runtime, so weldSeam() should work.
// Actual: doesn't compile - "value of type 'Drone' has no member 'weldSeam'"
// The compiler only knows first's static type, Drone
// (set by the array's element type), and Drone declares no weldSeam()
// Rule: member access is checked against the declared (compile-time) type,
// not the runtime type stored inside a reference.
// Fix: downcast at runtime - see the working version below.
*/

// Report 3, fixed:
if let welder = fleet[0] as? WelderDrone {
    print(welder.weldSeam())
}
// `as?` returns an optional because the cast can fail — a Drone
// reference could just as well be holding a ScannerDrone or CargoDrone
// at runtime, so the compiler hands back nil instead of crashing.

/*
// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
// Expectation: prints "thruster T-1", since Thruster defines its own label().
// Actual: compiles, and prints "generic component" - it lies.
// Rule: componentID is a protocol *requirement*, so it's dispatched dynamically through the witness
// table to whatever concrete type is stored. label() is only an extension method, not a requirement, so
// calls through a protocol-typed value like (parts: [Labelled]) are resolved statically at compile time against Labelled's own extension
// Fix: add `func label() -> String` to the Labelled protocol itself.
*/


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly; a protocol-based redesign;
// two or three sentences comparing them.

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?

    `mutating` exists to tell the compiler "this method may replace
    `self`'s stored properties, so treating `self` as a var and disallowing calling it on a `let` instance
    or through an immutable binding." This only applies to value types, whose instances are their own storage.
    A class instance is a reference to storage living on the heap, so calling a method through that reference never
    needs to replace `self` itself, so the keyword is meaningless for classes and Swift
    simply doesn't require it.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:

    Inheritance lets subclasses share actual implemented state and enforce an unbreakable rule via `final` (like runOnce()) - a single
    base class can guarantee a method body can never be overridden.
    Protocols cannot do that, any suitable type can always supply
    its own implementation of the requirement. But a protocol can unite completely unrelated types like a class (Drone), a struct
    (SensorModule), and a type we don't own (LegacyBeacon) — under only one interface, while a single inheritance cannot.

 3. What does `final` prevent, and what did it protect in runOnce()?

    1) On a class, `final` prevents any further subclassing,
    2) on a method or property it prevents any subclass from overriding that
    
    On runOnce(), it protected the three-step shift ritual itself from being reordered, skipped or replaced by a subclass
    that wants to cheat.

 4. In Report 4, why did the protocol extension's method win?

    Because `label()` is not part of the Labelled protocol's requirement list, it exists only
    as a default implementation in a protocol extension.
    There is only dynamic dispatch to protocol requirements, anything else that merely matches a
    requirement's name by some coincidence, including non-requirement extension methods, is resolved statically
    against the variable's declared type.

*/
