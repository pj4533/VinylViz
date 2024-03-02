//
//  GeometryElement+Utils.swift
//  VinylViz
//
//  Created by PJ Gray on 3/1/24.
//

import ARKit
import RealityKit
import UIKit

extension GeometryElement {
    subscript(_ index: Int) -> [Int32] {
        precondition(bytesPerIndex == MemoryLayout<Int32>.size,
                     """
This subscript operator can only be used on GeometryElement instances with bytesPerIndex == \(MemoryLayout<Int32>.size).
This GeometryElement has bytesPerIndex == \(bytesPerIndex)
"""
        )
        var data = [Int32]()
        data.reserveCapacity(primitive.indexCount)
        for indexOffset in 0 ..< primitive.indexCount {
            data.append(buffer
                .contents()
                .advanced(by: (Int(index) * primitive.indexCount + indexOffset) * MemoryLayout<Int32>.size)
                .assumingMemoryBound(to: Int32.self).pointee)
        }
        return data
    }
    
    func asInt32Array() -> [Int32] {
        var data = [Int32]()
        let totalNumberOfInt32 = count * primitive.indexCount
        data.reserveCapacity(totalNumberOfInt32)
        for indexOffset in 0 ..< totalNumberOfInt32 {
            data.append(buffer.contents().advanced(by: indexOffset * MemoryLayout<Int32>.size).assumingMemoryBound(to: Int32.self).pointee)
        }
        return data
    }
    
    func asUInt16Array() -> [UInt16] {
        asInt32Array().map { UInt16($0) }
    }
    
    public func asUInt32Array() -> [UInt32] {
        asInt32Array().map { UInt32($0) }
    }
}
