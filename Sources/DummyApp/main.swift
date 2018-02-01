import Dummy
import Foundation

protocol Protocol {
  var typeName: String { get }
  var simpleStruct: SimpleStruct? { get }
}

extension Protocol {
  var typeName: String {
    return "\(type(of: self))"
  }
}

class SwiftClass: Protocol {
  var name: String = "A"
  var simpleStruct: SimpleStruct?
}

class ObjcClass: NSObject, Protocol{
  var simpleStruct: SimpleStruct?
}

class GenericClass<T: Protocol>: Protocol{
  var simpleStruct: SimpleStruct?
}

final class FinalSwiftClass: Protocol{
  var simpleStruct: SimpleStruct?
}

final class FinalObjcClass: NSObject, Protocol{
  var simpleStruct: SimpleStruct?
}

struct SimpleStruct {
  let int: Int
  let string: String
}


func data<T>(_ value: T) -> Data {
  if let cls = T.self as? AnyClass {
    let address = unsafeBitCast(value, to: UInt.self)
    let pointer = UnsafeRawPointer(bitPattern: address)!
    return Data(bytes: pointer, count: class_getInstanceSize(cls))
  }

  let size = MemoryLayout<T>.stride
  var dummyValue = value
  let dummyData = withUnsafePointer(to: &dummyValue) { pointer in
    Data(bytes: UnsafeRawPointer(pointer), count: size)
  }
  return dummyData
}

class Foo {
  let a: UInt32 = 0xaaaaaaaa
//  let b: UInt64? = 0xbbbbbbbb
  let string: String = "A"
}

// <38f00000 01000000 02000000 00000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 02000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 04000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 06000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 08000000 aaaaaaaa bbbbbbbb>

private final class SharedObject {
  static let instance = SharedObject()
}

func zero<T: AnyObject>() -> T {
  print("\(T.self)")
  let size = class_getInstanceSize(T.self)
  print("  size=\(size)")

  var buffer = Data()
  buffer.append(data(T.self)) // isa
  buffer.append(data(0x2))    // refCount - I don't know why it starts from 2

//  let alignment = class_getInstanceSize(SharedObject.self)
  let alignment = MemoryLayout<Int>.alignment
  for _ in (buffer.count / alignment)..<(size / alignment) {
//    buffer.append(data(SharedObject.instance))
    buffer.append(data(0))
  }

  print("Buf  :", buffer as NSData)
  var bytes = (buffer as NSData).bytes
  return withUnsafeMutablePointer(to: &bytes) {
    UnsafeMutableRawPointer($0).load(as: T.self)
  }
}

let zeroValue: Foo = zero()
let mirror = Mirror(reflecting: zeroValue)
//print("Value:", zeroValue)
print("Child:", mirror.children.count)

print("Foo  :", data(Foo()) as NSData)
print("Zero :", data(zeroValue) as NSData)

//let data = dummyData(from: zeroValue)
//let dummyValue: Foo = data.withUnsafeBytes { pointer in
//  UnsafeRawPointer(pointer).load(as: Foo.self)
//}
//print(dummyValue)

let instance: SwiftClass = dummy()
print(instance)
print(instance.name)
print(instance.simpleStruct)
//
