import Dummy
import XCTest

protocol Protocol {
  var typeName: String { get }
}

extension Protocol {
  var typeName: String {
    return "\(type(of: self))"
  }
}

class SwiftClass: Protocol {}
class ObjcClass: NSObject, Protocol {}
class GenericClass<T: Protocol>: Protocol {}
final class FinalSwiftClass: Protocol {}
final class FinalObjcClass: NSObject, Protocol {}

struct Struct: Protocol {
  let int: Int
  let intOptional: Int?
  let intImplicitlyUnwrappedOptional: Int!

  let float: Float
//  let floatOptional: Float?
//  let floatImplicitlyUnwrappedOptional: Float!

  let double: Double
  let doubleOptional: Double?
  let doubleImplicitlyUnwrappedOptional: Double!

  let string: String
  let stringOptional: String?
  let stringImplicitlyUnwrappedOptional: String!

  let array: [String]
  let arrayOptional: [String]?
  let arrayOptionalOptional: [String?]?
  let arrayImplicitlyUnwrappedOptional: [String]!

  let swiftClass: SwiftClass
  let swiftClassOptional: SwiftClass?
  let swiftClassImplicitlyUnwrappedOptional: SwiftClass!

  let objcClass: ObjcClass
  let objcClassOptional: ObjcClass?
  let objcClassImplicitlyUnwrappedOptional: ObjcClass!

  let classArray: [GenericClass<SwiftClass>]
  let classArrayOptional: [GenericClass<SwiftClass>?]?
  let classArrayImplicitlyUnwrappedOptional: [GenericClass<SwiftClass>?]!

  let dictionary: [String: SwiftClass]
  let dictionaryOptional: [String: SwiftClass?]?
  let dictionaryImplicitlyUnwrappedOptional: [String: SwiftClass?]!

  let `struct`: AnotherStruct
  let structOotional: AnotherStruct?
}

struct AnotherStruct: Protocol {
  let swiftClass: SwiftClass
  let swiftClassOptional: SwiftClass?

  let objcClass: ObjcClass
  let objcClassOptional: ObjcClass?

  let classArray: [GenericClass<SwiftClass>]
  let classArrayOptional: [GenericClass<SwiftClass>?]?

  let dictionary: [String: SwiftClass]
  let dictionaryOptional: [String: SwiftClass?]?
}

final class DummyTests: XCTestCase {
  func testSwiftClass() {
    let value: SwiftClass = dummy()
    XCTAssertNotNil("\(value)")
    XCTAssertTrue(value.typeName.contains("SwiftClass"))
  }

  func testObjcClass() {
    let value: ObjcClass = dummy()
    XCTAssertNotNil("\(value)")
    XCTAssertTrue(value.typeName.contains("ObjcClass"))
  }

  func testFinalSwiftClass() {
    let value: FinalSwiftClass = dummy()
    XCTAssertNotNil("\(value)")
    XCTAssertTrue(value.typeName.contains("FinalSwiftClass"))
  }

  func testFinalObjcClass() {
    let value: FinalObjcClass = dummy()
    XCTAssertNotNil("\(value)")
    XCTAssertTrue(value.typeName.contains("FinalObjcClass"))
  }

  func testGenericClass() {
    let value: GenericClass<SwiftClass> = dummy()
    XCTAssertNotNil("\(value)")
    XCTAssertTrue(value.typeName.contains("GenericClass<SwiftClass>"))
  }

  func testStruct() {
    let value: Struct = dummy()
    XCTAssertNotNil("\(value)")
    XCTAssertTrue(value.typeName.contains("Struct"))
  }
}
