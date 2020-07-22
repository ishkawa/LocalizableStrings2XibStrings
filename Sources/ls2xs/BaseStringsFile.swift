//
//  BaseStringsFile.swift
//  ls2xs
//
//  Created by 安宅正之 on 2020/07/23.
//

import Foundation

/// Temporary strings file in `Base.lproj`, containing key-value pair of `IbFile.ObjectId` and `Localization.Key`
///
/// This file is generated by `ibtool`.
/// Make sure that this file should be removed.
final class BaseStringsFile: CustomStringConvertible {
    let url: URL
    let fullname: String
    var keyValues: [IbFile.ObjectId: Localize.Key] = [:]

    static func make(ibFile: IbFile) -> BaseStringsFile {
        generate(from: ibFile, to: "\(ibFile.name).strings")
        return BaseStringsFile(ibFile: ibFile)
    }

    private static func generate(from ibFile: IbFile, to baseStringsFileName: String) {
        let generateStringsFile: Process = { task, ibFileUrl, baseStringsFileUrl in
            task.launchPath = "/usr/bin/ibtool"
            task.arguments = [
                ibFileUrl.path,
                "--generate-strings-file",
                baseStringsFileUrl.path,
            ]
            return task
        }(Process(), ibFile.url, ibFile.url.deletingLastPathComponent().appendingPathComponent(baseStringsFileName))
        generateStringsFile.launch()
        generateStringsFile.waitUntilExit()
    }

    init(ibFile: IbFile) {
        let fullname = "\(ibFile.name).strings"
        url = ibFile.url
            .deletingLastPathComponent()
            .appendingPathComponent(fullname)
        self.fullname = fullname

        keyValues = { url in
            guard let keyValues = NSDictionary(contentsOf: url) as? [IbFile.ObjectId: Localize.Key] else { fatalError("Failed to load IbFile: \(url)") }
            return keyValues
        }(url)
    }

    func removeFile() {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            fatalError("failed to remove file: \(url)")
        }
        return
    }

    var description: String { url.path }
    var isEmpty: Bool { keyValues.isEmpty }
}
