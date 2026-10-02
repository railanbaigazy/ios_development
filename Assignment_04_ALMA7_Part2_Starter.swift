import Playgrounds

#Playground {
    // =============================================================
    //  Station ALMA-7, Part II: The Teleporter Incident
    //  iOS Mobile Development · Module 4 · Lab Assignment
    //
    //  How to use:
    //   • Xcode: File → New → Playground → Blank, replace everything
    //     with this file's contents.
    //   • Terminal: swift ALMA7_Part2_Starter.swift
    //
    //  Rules:
    //   • Do NOT modify the STARTER DATA section.
    //   • `!` (force unwrap) is forbidden: −0.5 points each.
    //   • No map / filter / reduce / compactMap.
    //   • Default to struct. Use class only where the task says so.
    // =============================================================


    // MARK: - =================== STARTER DATA ===================
    // MARK: - Do not modify anything in this section

    /// Splits a line into fields.
    /// fields("crate:101:120")            -> ["crate", "101", "120"]
    /// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
    /// fields("junk")                     -> ["junk"]
    func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
        var result: [String] = []
        var current = ""
        for character in line {
            if character == separator {
                result.append(current)
                current = ""
            } else {
                current.append(character)
            }
        }
        result.append(current)
        return result
    }

    /// Cargo manifest as recovered from the damaged recorder.
    let rawManifest = [
        "crate:101:120",
        "container:KZ-ALM-7:340",
        "livestock:lab mice:12:2",
        "???-corrupted-line",
        "crate:102:75",
        "container:KZ-ALM-9:410",
        "livestock:ficus:3:5",
        "crate:103:260",
        "crate:104:abc",
        ""
    ]

    /// Oxygen readings. One of these deck names is not a real deck.
    let deckReadings: [(deck: String, oxygen: Int)] = [
        (deck: "bridge",     oxygen: 78),
        (deck: "lab",        oxygen: 64),
        (deck: "greenhouse", oxygen: 55),
        (deck: "cargo",      oxygen: 12),
        (deck: "medbay",     oxygen: 90),
        (deck: "engine",     oxygen: 41)
    ]

    /// Crew records, straight from the personnel file.
    let crewData: [(name: String, deck: String, oxygen: Int)] = [
        (name: "Timur",   deck: "engine", oxygen: 62),
        (name: "Dana",    deck: "lab",    oxygen: 48),
        (name: "Aigerim", deck: "bridge", oxygen: 91),
        (name: "Nurlan",  deck: "cargo",  oxygen: 17)
    ]

    print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

    // MARK: - ================= END OF STARTER DATA =================


    // MARK: - =================== YOUR SOLUTION ===================
    // Uncomment each declaration when you start working on it.


    // MARK: Level 1 · The Deck Register

    // 1.1
    enum Deck: String, CaseIterable {
        case bridge
        case lab
        case cargo
        case medbay
        case engine
        
        var evacuationPriority: Int {
            switch self {
            case .bridge:
                return 1
            case .medbay:
                return 2
            case .lab:
                return 3
            case .engine:
                return 4
            case .cargo:
                return 5
            }
        }
    }
    
    print("*** TASK 1 ***")
    for deck in Deck.allCases {
        print("Deck: \(deck), priority: \(deck.evacuationPriority)")
    }
    
    
    // 1.2
    enum AlarmLevel: Int {
        case green = 0
        case yellow
        case orange
        case red
        
        static func level(forTotalMass mass: Int) -> AlarmLevel {
            AlarmLevel(rawValue: mass / 500) ?? .red
        }
    }
    
    print("Level for 0kg:", AlarmLevel.level(forTotalMass: 0))
    print("Level for 940kg:", AlarmLevel.level(forTotalMass: 940))
    print("Level for 100kg:", AlarmLevel.level(forTotalMass: 1000))
    print("Level for 1500kg:", AlarmLevel.level(forTotalMass: 1500))
    print("Level for 2200kg:", AlarmLevel.level(forTotalMass: 2200))


    // MARK: Level 2 · The Manifest

    // 2.1
    enum ManifestEntry {
        case crate(id: Int, massKg: Int)
        case container(code: String, massKg: Int)
        case livestock(species: String, count: Int, massPerUnitKg: Int)
        case unknown(raw: String)
    }

    // 2.2
    func parseEntry(_ line: String) -> ManifestEntry {
        let entries = fields(line)
        
        switch entries[0] {
        case "crate":
            guard entries.count == 3,
                  let id = Int(entries[1]),
                  let massKg = Int(entries[2])
            else {
                return ManifestEntry.unknown(raw: line)
            }

            return ManifestEntry.crate(id: id, massKg: massKg)
        case "container":
            guard entries.count == 3,
                  let massKg = Int(entries[2])
            else {
                return ManifestEntry.unknown(raw: line)
            }

            return ManifestEntry.container(code: entries[1], massKg: massKg)
        case "livestock":
            guard entries.count == 4,
                  let count = Int(entries[2]),
                  let massPerUnitKg = Int(entries[3])
            else {
                return ManifestEntry.unknown(raw: line)
            }

            return ManifestEntry.livestock(species: entries[1], count: count, massPerUnitKg: massPerUnitKg)
        default:
            return ManifestEntry.unknown(raw: line)
        }
    }
    
    print("*** TASK 2 ***")
    for manifestEntry in rawManifest {
        print("\(manifestEntry): \(parseEntry(manifestEntry))")
    }

    // 2.3
    func mass(of entry: ManifestEntry) -> Int {
        switch entry {
        case let .crate(_, massKg):
            return massKg
        case let .container(_, massKg):
            return massKg
        case let .livestock(_, count, massPerUnitKg):
            return count * massPerUnitKg
        default:
            return 0
        }
    }
    
    var manifestTotalMass = 0
    var manifestUnknownsCount = 0
    
    for manifestEntry in rawManifest {
        let manifest = parseEntry(manifestEntry)
        
        if case .unknown = manifest {
            manifestUnknownsCount += 1
        }
        
        manifestTotalMass += mass(of: manifest)
    }
    
    print("manifest unknown count:", manifestUnknownsCount)

    let A = manifestTotalMass
    print("manifest total mass: \(manifestTotalMass)kg")

    // MARK: Level 3 · Crew Snapshots

    // 3.1
    struct CrewSnapshot {
        let name: String
        var deck: Deck
        var oxygen: Int
        
        mutating func breathe(_ amount: Int) {
            self.oxygen = max(oxygen - amount, 0)
        }

        mutating func move(to deck: Deck) {
            self.deck = deck
        }

        mutating func reviveInMedbay() {
            self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
        }

        static func rookie(named name: String) -> CrewSnapshot {
            CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
        }
    }

    // 3.2
    var crewRoster: [CrewSnapshot] = []
    
    print("*** TASK 3 ***")
    print("Converting crewData into crewRoster...")
    
    for data in crewData {
        guard let deck = Deck(rawValue: data.deck) else {
            print("deck type not valid (\(data.deck))")
            continue
        }
        crewRoster.append(CrewSnapshot(name: data.name, deck: deck, oxygen: data.oxygen))
    }

    // 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
    print("Prove it's a value type:")

    func drainPlain(_ snapshot: CrewSnapshot) {
        var snapshot = snapshot
        snapshot.oxygen = 0
    }

    func drainInout(_ snapshot: inout CrewSnapshot) {
        snapshot.oxygen = 0
    }

    // 1. copy modified, original unchanged
    var snapshotOriginal = CrewSnapshot.rookie(named: "Aigerim")
    var snapshotCopy = snapshotOriginal
    print("1. copy before - original.oxygen: \(snapshotOriginal.oxygen), copy.oxygen: \(snapshotCopy.oxygen)")
    snapshotCopy.oxygen = 0
    print("1. copy after  - original.oxygen: \(snapshotOriginal.oxygen), copy.oxygen: \(snapshotCopy.oxygen)")

    // 2. plain parameter, original unchanged
    var snapshotForPlainCall = CrewSnapshot.rookie(named: "Dana")
    print("2. plain before - original.oxygen: \(snapshotForPlainCall.oxygen)")
    drainPlain(snapshotForPlainCall)
    print("2. plain after  - original.oxygen: \(snapshotForPlainCall.oxygen)")

    // 3. inout parameter, original changed
    var snapshotForInoutCall = CrewSnapshot.rookie(named: "Nurlan")
    print("3. inout before - original.oxygen: \(snapshotForInoutCall.oxygen)")
    drainInout(&snapshotForInoutCall)
    print("3. inout after  - original.oxygen: \(snapshotForInoutCall.oxygen)")


    // MARK: Level 4 · The Teleport Pod

    // 4.1
    final class TeleportPod {
        let id: String
        var chargeLevel: Int
        var occupant: CrewSnapshot?
        
        init(id: String, chargeLevel: Int) {
            self.id = id
            self.chargeLevel = chargeLevel
            self.occupant = nil
        }
        
        func load(_ crew: CrewSnapshot) -> Bool {
            if self.occupant != nil || self.chargeLevel < 20 {
                return false
            }
            
            self.occupant = crew
            return true
        }
        
        func fire() -> CrewSnapshot? {
            guard let firedOccupant = self.occupant else {
                return nil
            }
            
            self.chargeLevel = max(self.chargeLevel - 20, 0)
            self.occupant = nil
            
            return firedOccupant
        }
    }

    // 4.2 · Charge ledger: load+fire three times, then fire an empty pod
    print("*** TASK 4 ***")
    let teleportPod = TeleportPod(id: "P-1", chargeLevel: 100)
    
    for i in [0, 1, 3] {
        let loaded = teleportPod.load(crewRoster[i])
        print("Loading \(crewRoster[i].name)... \(loaded ? "success" : "fail")")
        let fired = teleportPod.fire()
        print("Firing \(fired?.name ?? "no one")...")
        print(teleportPod.chargeLevel, "charge left")
    }
    
    _ = teleportPod.fire()
    print("Firing an empty pod")
    
    let C = teleportPod.chargeLevel
    print(C, "charge left\n")

    // 4.3 · Reference-semantics demonstration

    let pod = TeleportPod(id: "1", chargeLevel: 100)
    let podCopy = pod
    
    print("copy before - original.chargeLevel: \(pod.chargeLevel), copy.chargeLevel: \(podCopy.chargeLevel)")
    podCopy.chargeLevel = 0
    print("copy after - original.chargeLevel: \(pod.chargeLevel), copy.chargeLevel: \(podCopy.chargeLevel)")
    
    var snapshot4 = CrewSnapshot(name: "Railan", deck: .cargo, oxygen: 100)
    var snapshot4Copy = snapshot4
    
    print("copy before - original.oxygen: \(snapshot4.oxygen), copy.oxygen: \(snapshot4Copy.oxygen)")
    snapshot4Copy.oxygen = 0
    print("copy after - original.oxygen: \(snapshot4.oxygen), copy.oxygen: \(snapshot4Copy.oxygen)")

    // Rule: assigning a class instance copies the reference, so original an copy mutate it together
    // but assigning a struct copies the value, so original and copy store its own storage

    // MARK: Level 5 · Station Systems

    // 5.1
    final class Station {
        let callSign: String = "ALMA-7"

        var hullIntegrity: Int = 100 {
            willSet {
                print("hullIntegrity changing from \(self.hullIntegrity) to \(newValue)")
            }
            didSet {
                if hullIntegrity > 100 {
                    hullIntegrity = 100
                } else if hullIntegrity < 0 {
                    hullIntegrity = 0
                }
            }
        }

        lazy var fullDiagnostics: String = {
            print("Running full scan...")
            
            return "Diagnostics for \(callSign): hull \(hullIntegrity)%, totalOxygen \(totalOxygen), averageOxygen \(averageOxygen)"
        }()

        var oxygenByDeck: [Deck: Int]

        var totalOxygen: Int {
            var total = 0
            
            for oxygen in self.oxygenByDeck.values {
                total += oxygen
            }
            
            return total
        }

        var averageOxygen: Int {
            get {
                self.totalOxygen / self.oxygenByDeck.count
            }
            set {
                for deck in oxygenByDeck.keys {
                    self.oxygenByDeck[deck] = newValue
                }
            }
        }

        init(deckReadings: [(deck: String, oxygen: Int)]) {
            var oxygenByDeck: [Deck: Int] = [:]
            
            for reading in deckReadings {
                guard let deck = Deck(rawValue: reading.deck) else { continue }
                oxygenByDeck[deck] = reading.oxygen
            }
            
            self.oxygenByDeck = oxygenByDeck
        }
    }

    print("*** TASK 5 ***")
    let station = Station(deckReadings: deckReadings)

    let B = station.averageOxygen
    print("average oxygen at start:", B)

    print("fullDiagnostics untouched so far - no \"Running full scan...\" above this line")
    print(station.fullDiagnostics)
    print(station.fullDiagnostics)

    // 5.2 · The clamp trap: 130, then -40, then 55
    
    station.hullIntegrity = 130
    print("hullIntegrity after setting to 130:", station.hullIntegrity)

    station.hullIntegrity = -40
    print("hullIntegrity after setting to -40:", station.hullIntegrity)

    station.hullIntegrity = 55
    print("hullIntegrity after setting to 55:", station.hullIntegrity)

    // reassignment in didSet is an assignment to hullIntegrity, so it triggers
    // willSet/didSet again but that nested call has its base case: once the value
    // has been forced to exactly 100 or 0, it no longer satisfies > 100 or < 0,
    // so nested didSet makes no further


    // MARK: Level 6 · Incident Reports
    // Three of these compile and are wrong. One does not compile.
    // For each: expectation, actual behaviour, the language rule, the fix.

    /*
    // Report 1 - compiles, wrong result
    var roster = crewRoster
    for var member in roster {
        member.oxygen -= 10          // mutates member, a value-type copy never touches roster's storage
    }
    print(roster[0].oxygen)   // author expected the crew to have lost oxygen - this is unchanged

    // Report 2 - compiles, wrong result
    let podA = TeleportPod(id: "A", chargeLevel: 100)
    let podB = podA                   // copies the reference, not the instance - podA and podB are the same object
    podB.chargeLevel = 0
    print(podA.chargeLevel)   // author expected 100, but this prints 0

    // Report 3 - does not compile
    struct Logbook {
        var entries: [String] = []
        func add(_ entry: String) {      // no mutating -> self is immutable inside this method
            entries.append(entry)
        }
    }

    // Report 4 - does not compile
    let snapshot = CrewSnapshot.rookie(named: "Dana")
    snapshot.oxygen = 40      // error: struct let freezes the whole value and its properties included

    let pod = TeleportPod(id: "B", chargeLevel: 50)
    pod.chargeLevel = 10      // fine: class - let only freezes the reference
    */

    // Fixed version
    do {
        // Report 1
        var roster = crewRoster
        for index in roster.indices {
            roster[index].oxygen -= 10
        }
        print(roster[0].oxygen)

        // Report 2
        let podA = TeleportPod(id: "A", chargeLevel: 100)
        let podB = TeleportPod(id: podA.id, chargeLevel: podA.chargeLevel)
        podB.chargeLevel = 0
        print(podA.chargeLevel)

        // Report 3
        struct Logbook {
            var entries: [String] = []
            mutating func add(_ entry: String) {
                entries.append(entry)
            }
        }

        // Report 4
        var snapshot = CrewSnapshot.rookie(named: "Dana")
        snapshot.oxygen = 40

        let pod = TeleportPod(id: "B", chargeLevel: 50)
        pod.chargeLevel = 10
    }


    // MARK: Level 7 · Sealing the Black Box

    // The leaky original:
    //
    // class FlightRecorder {
    //     var entries: [String] = []
    //     var isSealed = false
    // }
    //
    // Your sealed version below. One comment per access keyword.

    final class FlightRecorder {
        private var entries: [String] = []

        private(set) var isSealed = false

        internal var entryCount: Int {
            self.entries.count
        }

        internal func add(_ entry: String) {
            guard !self.isSealed else { return }
            entries.append(entry)
        }

        internal func seal() {
            self.isSealed = true
        }

        fileprivate func transcriptLines() -> [String] {
            self.entries
        }
    }

    func auditTranscript(of recorder: FlightRecorder) -> String {
        var transcript = ""
        
        for line in recorder.transcriptLines() {
            transcript += line + "\n"
        }
        
        return transcript
    }

    print("*** TASK 7 ***")
    let recorder = FlightRecorder()
    
    recorder.add("engine check nominal")
    recorder.add("oxygen levels stable")
    
    print("entry count:", recorder.entryCount)
    print(auditTranscript(of: recorder))

    recorder.seal()
    recorder.add("late entry - should be rejected")
    print("entry count after seal:", recorder.entryCount)

    // attempts to break the recorder from outside type that fail to compile:
    // recorder.entries = []
    // error: 'entries' is inaccessible due to 'private' protection level

    // recorder.isSealed = false
    // error: cannot assign to property: 'isSealed' setter is inaccessible


    // MARK: Finale · Integrity Code

    let D = AlarmLevel.level(forTotalMass: A).rawValue
    let integrityCode = "\(A)-\(B)-\(C)-\(D)"
    print("INTEGRITY CODE: \(integrityCode)")

    // MARK: Bonus

    // deinit in TeleportPod, a do-block lifetime experiment, and === identity


    // MARK: - ================= DEFENSE QUESTIONS =================
    /*
     1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
     
     Swift automatically sets init for all structs that don't declare init
     CrewSnapshot didnt wrote init, so it got init(name:deck:oxygen:) for free.
     Classes don't get a synthesized memberwise init, so TeleportPod had no initializer at
     until I wrote init(id:chargeLevel:) by myself.

     2. What does `mutating` do to self, and why do classes never need it?
     
     `mutating` lets a struct method treat `self` as a `var` while calling the method,
     so it can reassign properties or replace `self`. Without it, `self` is implicitly a `let`
     inside the method because we know that structs are value types.
     Classes don't need this because `self` always is a
     reference here, and even `let` freezes the reference, its properties can be changed.

     3. In Report 4 both values are `let`. What exactly does `let` freeze for a
        struct, and what does it freeze for a class?
     
     For a CrewSnapshot struct, `let` freezes the entire value, so changing any property will replace
     the whole value, which is forbidden by `let`.
     For a TeleportPod class, `let` only freezes the instanc's reference and its own `var`
     properties stay mutable using that same reference.

     4. Why must a lazy property be var? When does lazy change behaviour, not
        just performance?
     
     `lazy` must be `var` because its value isn't computed until the first access,
     and it has to be writable at that later time.
     Laziness changes the behavior when the mutable state is read: a compited stores
     the actual latest value and the lazy will store only the state it got on the first access.

     5. private vs fileprivate: where in your FlightRecorder would private be
        too strict?
     
     transcriptLines() is marked fileprivate so the function auditTranscript(of:)
     - which lives outside the class and in the same file - can call it.
     If transcriptLines() was private instead, it can be called only in the scope of the class,
     so auditTranscript(of:) would fail to compile.

     Bonus. On which line does deinit fire, and why can't === be used on
     CrewSnapshot?
    */

}
