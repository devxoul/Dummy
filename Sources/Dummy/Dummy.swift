import Foundation

public func dummy<T>() -> T {
  let zeroFilledDummy: T = zeroFilledValue()

  print("Zero :", _data(zeroFilledDummy) as NSData)

  let prefix: Data?
  if T.self is AnyObject.Type {
    prefix = Data(_data(zeroFilledDummy, isOptional: false).prefix(16))
  } else {
    prefix = nil
  }

  let data = dummyData(from: zeroFilledDummy, prefix: prefix)
  print("Dummy:", data as NSData)
  return data.withUnsafeBytes { pointer in
    return UnsafeRawPointer(pointer).load(as: T.self)
  }
}


public func dummy<T>(_ type: T.Type) -> T {
  return dummy()
}

private class Dummy<T> {}

private final class SharedObject {
  static let instance = SharedObject()
}

private func data<T>(_ value: T, isOptional: Bool = false) -> Data {
  if isOptional {
    return data(value as T?, isOptional: false)
  }
  if let cls = T.self as? AnyClass {
    let address = unsafeBitCast(value, to: UInt.self)
    let pointer = UnsafeRawPointer(bitPattern: address)!
    return Data(bytes: pointer, count: class_getInstanceSize(cls))
  } else {
    let size = MemoryLayout<T>.stride
    var dummyValue = value
    return withUnsafePointer(to: &dummyValue) { pointer in
      Data(bytes: UnsafeRawPointer(pointer), count: size)
    }
  }
}
private func _data<T>(_ value: T, isOptional: Bool = false) -> Data {
  return data(value, isOptional: isOptional)
}

private func zeroFilledValue<T>() -> T {
  if let cls = T.self as? AnyObject.Type {
    let size = class_getInstanceSize(cls)

    var buffer = Data()
    buffer.append(data(T.self)) // isa
    buffer.append(data(0x2))    // refCount - I don't know why it starts from 2

    let alignment = MemoryLayout<Int>.alignment
    for _ in (buffer.count / alignment)..<(size / alignment) {
      buffer.append(data(0))
    }

    var bytes = (buffer as NSData).bytes
    return withUnsafeMutablePointer(to: &bytes) {
      UnsafeMutableRawPointer($0).load(as: T.self)
    }
  }

  let stride = MemoryLayout<T>.stride
  let alignment = MemoryLayout<T>.alignment
  let pointer = UnsafeMutableRawPointer.allocate(bytes: stride, alignedTo: alignment)
  for i in 0..<(stride / alignment) {
    pointer.storeBytes(of: SharedObject.instance, toByteOffset: i * alignment, as: AnyObject.self)
  }
  return pointer.load(as: T.self)
}

func dummyData(from value: Any, prefix: Data? = nil) -> Data {
  var buffer = Data()
  if let prefix = prefix {
    buffer.append(prefix)
  }
  print("BUF  :", buffer as NSData)

  let mirror = Mirror(reflecting: value)
  for (label, value) in mirror.children.lazy {
    let valueType = type(of: value)
    var typeName = String(describing: valueType)
    var isOptional = false
    print("let", (label ?? "") + ":", typeName)

    while typeName.hasPrefix("Optional<") || typeName.hasPrefix("ImplicitlyUnwrappedOptional<") {
      let prefix = typeName.hasPrefix("Optional<") ? "Optional<" : "ImplicitlyUnwrappedOptional<"
      let startIndex = typeName.index(typeName.startIndex, offsetBy: prefix.count)
      let endIndex = typeName.index(before: typeName.endIndex)
      typeName = String(typeName[startIndex..<endIndex])
      isOptional = true
    }

    switch typeName {
    case "Int": buffer.append(data(0 as Int, isOptional: isOptional))
    case "Int8": buffer.append(data(0 as Int8, isOptional: isOptional))
    case "Int16": buffer.append(data(0 as Int16, isOptional: isOptional))
    case "Int32": buffer.append(data(0 as Int32, isOptional: isOptional))
    case "Int64": buffer.append(data(0 as Int64, isOptional: isOptional))

    case "UInt": buffer.append(data(0 as UInt, isOptional: isOptional))
    case "UInt8": buffer.append(data(0 as UInt8, isOptional: isOptional))
    case "UInt16": buffer.append(data(0 as UInt16, isOptional: isOptional))
    case "UInt32": buffer.append(data(0 as UInt32, isOptional: isOptional))
    case "UInt64": buffer.append(data(0 as UInt64, isOptional: isOptional))

    case "Float":
      if isOptional {
        buffer.append(data(0 as Float?, isOptional: isOptional))
      } else {
        break // I don't know why
      }
    case "Double": buffer.append(data(0 as Double, isOptional: isOptional))
    case "String": buffer.append(data("", isOptional: isOptional))

    case _ where typeName.hasPrefix("Array<"):
      buffer.append(data([Any](), isOptional: isOptional))

    case _ where typeName.hasPrefix("Dictionary<"):
      buffer.append(data([AnyHashable: Any](), isOptional: isOptional))

    case _ where valueType is AnyObject.Type:
//      buffer.append(data(dummy() as AnyObject, isOptional: isOptional))
      buffer.append(data(SharedObject.instance as AnyObject, isOptional: isOptional))

    default:
      buffer.append(contentsOf: dummyData(from: value))
    }
  }
  return buffer
}
