import Dummy
import Foundation

class SwiftClass {
  var name: String = "A"
  var simpleStruct: SimpleStruct?
}

struct SimpleStruct {
//  let int: Int
  let string: String
  let swiftClass: SwiftClass
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
  let a: UInt16 = 0x0//aaaa
//  let b: UInt16? = 0xbbbb
  let string: String = ""
  let simpleStruct: SimpleStruct? = nil
}

// <38f00000 01000000 02000000 00000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 02000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 04000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 06000000 aaaaaaaa bbbbbbbb>
// <38f00000 01000000 02000000 08000000 aaaaaaaa bbbbbbbb>

func zero<T: AnyObject>() -> T {
  print("\(T.self)")
  let size = class_getInstanceSize(T.self)
  print("  size=\(size)")

  var buffer = Data()
  buffer.append(data(T.self)) // isa
  buffer.append(data(0x2))    // refCount - I don't know why it starts from 2

  let alignment = MemoryLayout<Int>.alignment
  for _ in (buffer.count / alignment)..<(size / alignment) {
    buffer.append(data(0))
  }

  print("!Buf :", buffer as NSData)
  var bytes = (buffer as NSData).bytes
  return withUnsafeMutablePointer(to: &bytes) {
    UnsafeMutableRawPointer($0).load(as: T.self)
  }
}

let zeroValue: Foo = zero()
//print("Value:", zeroValue)
//let mirror = Mirror(reflecting: zeroValue)
//print("Child:", mirror.children.count)

print("!Foo :", data(Foo()) as NSData)
print("!Zero:", data(zeroValue) as NSData)
//print((zero() as Foo).simpleStruct as Any)
//print((zero() as Foo).simpleStruct?.swiftClass.name as Any)
//print((zero() as Foo).simpleStruct?.swiftClass.simpleStruct as Any)

//let data = dummyData(from: zeroValue)
//let dummyValue: Foo = data.withUnsafeBytes { pointer in
//  UnsafeRawPointer(pointer).load(as: Foo.self)
//}
//print(dummyValue)

let instance: Foo = dummy()
print(instance)
print(instance.simpleStruct)
//print(instance.b)
//print(instance.string)
//print(instance.name)
//print(instance.simpleStruct)

