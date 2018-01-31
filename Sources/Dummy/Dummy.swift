import Foundation

public func dummy<T>() -> T {
  // reference type
  if T.self is AnyObject.Type {
    return unsafeBitCast(Dummy<T>(), to: T.self)
  }

  // value type
  let zeroFilledDummy: T = zeroFilledValue()
  let data = dummyData(from: zeroFilledDummy)
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

private func zeroFilledValue<T>() -> T {
  let stride = MemoryLayout<T>.stride
  let alignment = MemoryLayout<T>.alignment
  let pointer = UnsafeMutableRawPointer.allocate(bytes: stride, alignedTo: alignment)
  for i in 0..<(stride / alignment) {
    pointer.storeBytes(of: SharedObject.instance, toByteOffset: i * alignment, as: AnyObject.self)
  }
  return pointer.bindMemory(to: T.self, capacity: stride).pointee
}

private func dummyData(from value: Any) -> Data {
  var data = Data()

  func append<T>(_ value: T, isOptional: Bool) {
    if isOptional {
      return append(value as T?, isOptional: false)
    }
    let size = MemoryLayout<T>.stride
    var dummyValue = value
    let dummyData = withUnsafePointer(to: &dummyValue) { pointer in
      Data(bytes: UnsafeRawPointer(pointer), count: size)
    }
    data.append(dummyData)
  }

  let mirror = Mirror(reflecting: value)
  for (_, value) in mirror.children.lazy {
    let valueType = type(of: value)
    var typeName = String(describing: valueType)
    var isOptional = false

    while typeName.hasPrefix("Optional<") || typeName.hasPrefix("ImplicitlyUnwrappedOptional<") {
      let prefix = typeName.hasPrefix("Optional<") ? "Optional<" : "ImplicitlyUnwrappedOptional<"
      let startIndex = typeName.index(typeName.startIndex, offsetBy: prefix.count)
      let endIndex = typeName.index(before: typeName.endIndex)
      typeName = String(typeName[startIndex..<endIndex])
      isOptional = true
    }

    switch typeName {
    case "Int": append(0 as Int, isOptional: isOptional)
    case "Int8": append(0 as Int8, isOptional: isOptional)
    case "Int16": append(0 as Int16, isOptional: isOptional)
    case "Int32": append(0 as Int32, isOptional: isOptional)
    case "Int64": append(0 as Int64, isOptional: isOptional)

    case "UInt": append(0 as UInt, isOptional: isOptional)
    case "UInt8": append(0 as UInt8, isOptional: isOptional)
    case "UInt16": append(0 as UInt16, isOptional: isOptional)
    case "UInt32": append(0 as UInt32, isOptional: isOptional)
    case "UInt64": append(0 as UInt64, isOptional: isOptional)

    case "Float": break // I don't know why
    case "Double": append(0 as Double, isOptional: isOptional)
    case "String": append("", isOptional: isOptional)

    case _ where typeName.hasPrefix("Array<"):
      append([Any](), isOptional: isOptional)

    case _ where typeName.hasPrefix("Dictionary<"):
      append([AnyHashable: Any](), isOptional: isOptional)

    case _ where valueType is AnyObject.Type:
      append(SharedObject.instance as AnyObject, isOptional: isOptional)

    default:
      data.append(contentsOf: dummyData(from: value))
    }
  }
  return data
}
