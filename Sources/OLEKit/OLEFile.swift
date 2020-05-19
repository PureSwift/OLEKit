import Foundation

enum OLEError: Error, Equatable {
  case fileIsNotOLE
  case incorrectCLSID
  case incompleteHeader
  case incorrectSectorSize
  case incorrectDLLVersion
  case bigEndianNotSupported
  case incorrectMiniSectorSize
  case incorrectHeaderReservedBytes
  case incorrectMiniStreamCutoffSize
  case incorrectNumberOfDirectorySectors
}

public final class OLEFile {
  private let fileHandle: FileHandle
  public let header: Header

  public init(_ url: URL) throws {
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    // swiftlint:disable:next force_cast
    let fileSize = attributes[FileAttributeKey.size] as! UInt64

    fileHandle = try FileHandle(forReadingFrom: url)

    #if compiler(>=5.1)
    guard let data = try fileHandle.read(upToCount: 512)
    else { throw OLEError.incompleteHeader }
    #else
    guard fileSize >= 512
    else { throw OLEError.incompleteHeader }

    let data = try fileHandle.readData(ofLength: 512)
    #endif

    var stream = DataStream(data)
    header = try Header(&stream, fileSize: fileSize)
  }
}