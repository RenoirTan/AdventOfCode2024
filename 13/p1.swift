import Foundation

func get_gcd(_ a: Int, _ b: Int) -> Int {
    var (x, y) = (a, b)
    while y != 0 {
        (x, y) = (y, x % y)
    }
    return x
}

// get x and y for ax + by = gcd(a, b)
func extended_euclidean(_ a: Int, _ b: Int) -> (Int, Int, Int) {
    var qs: [Int] = [0, 0, 0]
    var rs: [Int] = (a >= b) ? [a, b, 0] : [b, a, 0]
    var ss: [Int] = (a >= b) ? [1, 0, 0] : [0, 1, 0]
    var ts: [Int] = (a >= b) ? [0, 1, 0] : [1, 0, 0]
    var i = 2
    while rs[(i - 1) % 3] != 0 {
        qs[i % 3] = rs[(i - 2) % 3] / rs[(i - 1) % 3]
        rs[i % 3] = rs[(i - 2) % 3] - qs[i % 3] * rs[(i - 1) % 3]
        ss[i % 3] = ss[(i - 2) % 3] - qs[i % 3] * ss[(i - 1) % 3]
        ts[i % 3] = ts[(i - 2) % 3] - qs[i % 3] * ts[(i - 1) % 3]
        i += 1
    }
    // gcd, x, y
    return (rs[(i - 2) % 3], ss[(i - 2) % 3], ts[(i - 2) % 3])
}

let COST_RATIO = 3

// ca + db = e
// fa + gb = h
//
// g(ca + db) - d(fa + gb) = ge - dh
// a(gc - df) = ge - dh
// a = (ge - dh) / (gc - df)
func simul_eq(_ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int) -> (Int, Int) {
    if (c > e && d > e) || (f > h && g > h) {
        return (0, 0)
    }
    let a_side = (c * g) - (f * d)
    if a_side == 0 { // both vectors are parallel
        // check if position vector to destination is parallel to button vectors
        if (Float(h) / Float(e) != Float(f) / Float(c)) {
            return (0, 0)
        }
        // linear diophantine equation
        // https://math.stackexchange.com/a/20727
        var (gcd, a, b) = extended_euclidean(c, d)
        if e % gcd != 0 {
            return (0, 0)
        }
        let ratio = e / gcd
        a *= ratio
        b *= ratio
        let j = d / gcd
        let k = c / gcd
        let r_max = a / j
        let r_min = -(b / k)
        // print(ratio, a, b, j, k, r_min, r_max)
        if r_min > r_max {
            return (0, 0)
        }
        if (c / d) > COST_RATIO || d > e { // button a is more worth it or button b is impossible
            return (a - r_min * j, b + r_min * k)
        } else {
            return (a - r_max * j, b + r_max * k)
        }
    }
    let rhs = (e * g) - (h * d)
    if rhs % a_side != 0 {
        return (0, 0)
    }
    let a = rhs / a_side
    let b = (e - (c * a)) / d
    if a >= 0 && b >= 0 {
        return (a, b)
    } else {
        return (0, 0)
    }
}

let argv = CommandLine.arguments
let argc = argv.count
if argc < 2 {
    print("No file included!")
    exit(1)
}

let fp = URL(string: argv[1])!
let fileHandle = try FileHandle(forReadingFrom: fp)
defer {
    fileHandle.closeFile()
}

let buffer = try fileHandle.readToEnd()!
var line_no = 0
var sum = 0
var (c, d, e, f, g, h) = (0, 0, 0, 0, 0, 0)
// for some reason I can't use regex literals
let two_ints = try Regex(#"(\d+)[^\d]*(\d+)"#)
let content = String(data: buffer, encoding: .utf8)!
func ahh(_ line: String, _: inout Bool) -> Void {
    if line_no % 4 != 3 {
        let matches = (try? two_ints.firstMatch(in: line))!
        let n0 = Int(matches[1].substring!)!
        let n1 = Int(matches[2].substring!)!
        if line_no % 4 == 0 {
            (c, f) = (n0, n1)
        } else if line_no % 4 == 1 {
            (d, g) = (n0, n1)
        } else if line_no % 4 == 2 {
            (e, h) = (n0, n1)
            let (a, b) = simul_eq(c, d, e, f, g, h)
            // print(a, b, c, d, e, f, g, h)
            sum += 3*a + b
        }
    }
    line_no += 1
}
content.enumerateLines(invoking: ahh) // for some reason I can't just use a block
print(sum)