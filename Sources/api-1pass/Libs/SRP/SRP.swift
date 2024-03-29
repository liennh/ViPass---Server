import Foundation
import BigInt
import Cryptor


/// Creates the salted verification key based on a user's username and
/// password. Only the salt and verification key need to be stored on the
/// server, there's no need to keep the plain-text password. 
///
/// Keep the verification key private, as it can be used to brute-force 
/// the password from.
///
/// - Parameters:
///   - username: user's username
///   - password: user's password
///   - salt: (optional) custom salt value; if providing a salt, make sure to
///       provide a good random salt of at least 16 bytes. Default is to
///       generate a salt of 16 bytes.
///   - group: `Group` parameters; default is 2048-bits group.
///   - algorithm: which `Digest.Algorithm` to use; default is SHA1.
/// - Returns: salt (s) and verification key (v)
public func createSaltedVerificationKey(
    username: String,
    password: String,
    salt: Data? = nil,
    group: Group = .N3072,
    algorithm: Digest.Algorithm = .sha1)
    -> (salt: Data, verificationKey: Data)
{
    let salt = salt ?? Data(bytes: try! Random.generate(byteCount: 16)) // 16
    let x = calculate_x(algorithm: algorithm, salt: salt, username: username, password: password)
    return createSaltedVerificationKey(from: x, salt: salt, group: group)
}

/// Creates the salted verification key based on a precomputed SRP x value.
/// Only the salt and verification key need to be stored on the
/// server, there's no need to keep the plain-text password.
///
/// Keep the verification key private, as it can be used to brute-force
/// the password from.
///
/// - Parameters:
///   - x: precomputed SRP x
///   - salt: (optional) custom salt value; if providing a salt, make sure to
///       provide a good random salt of at least 16 bytes. Default is to
///       generate a salt of 16 bytes.
///   - group: `Group` parameters; default is 2048-bits group.
/// - Returns: salt (s) and verification key (v)
public func createSaltedVerificationKey(
    from x: Data,
    salt: Data? = nil,
    group: Group = .N3072)
    -> (salt: Data, verificationKey: Data)
{
    return createSaltedVerificationKey(from: BigUInt(x), salt: salt, group: group)
}

func createSaltedVerificationKey(
    from x: BigUInt,
    salt: Data? = nil,
    group: Group = .N3072)
    -> (salt: Data, verificationKey: Data)
{
    let salt = salt ?? Data(bytes: try! Random.generate(byteCount: 16))
    let v = calculate_v(group: group, x: x)
    return (salt, v.serialize())
}

func pad(_ data: Data, to size: Int) -> Data {
    precondition(size >= data.count, "Negative padding not possible")
    return Data(count: size - data.count) + data
}

//u = H(PAD(A) | PAD(B))
func calculate_u(group: Group, algorithm: Digest.Algorithm, A: Data, B: Data) -> BigUInt {
    let H = Digest.hasher(algorithm)
    let size = group.N.serialize().count
    return BigUInt(H(pad(A, to: size) + pad(B, to: size)))
}

//M1 = H(H(N) XOR H(g) | H(U) | s | A | B | K)
func calculate_M(group: Group, algorithm: Digest.Algorithm, u: BigUInt, salt: Data, A: Data, B: Data, K: Data) -> Data {
    let H = Digest.hasher(algorithm)
    let HN_xor_Hg = (H(group.N.serialize()) ^ H(group.g.serialize()))!
    //let HI = H(username.data(using: .utf8)!)
    let HU = H(u.serialize())
    return H(HN_xor_Hg + HU + salt + A + B + K)
}

//HAMK = H(A | M | K)
func calculate_HAMK(algorithm: Digest.Algorithm, A: Data, M: Data, K: Data) -> Data {
    let H = Digest.hasher(algorithm)
    return H(A + M + K)
}

//k = H(N | PAD(g))
func calculate_k(group: Group, algorithm: Digest.Algorithm) -> BigUInt {
    let H = Digest.hasher(algorithm)
    let size = group.N.serialize().count
    return BigUInt(H(group.N.serialize() + pad(group.g.serialize(), to: size)))
}

//x = H(s | H(I | ":" | P))
func calculate_x(algorithm: Digest.Algorithm, salt: Data, username: String, password: String) -> BigUInt {
    let H = Digest.hasher(algorithm)
    return BigUInt(H(salt + H("\(username):\(password)".data(using: .utf8)!)))
}

// v = g^x % N
func calculate_v(group: Group, x: BigUInt) -> BigUInt {
    return group.g.power(x, modulus: group.N)
}
