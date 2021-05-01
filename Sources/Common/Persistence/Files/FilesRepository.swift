//
//  FilesRepository.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation
import RxSwift

class FilesRepository<Model: Codable & Identifiable>: RepositoryType {
    
    typealias EncodingMethod = ([Model]) throws -> Data
    typealias DecodingMethod = (Data) throws -> [Model]
    
    private let fileHandler: FileHandle
    private let encode: EncodingMethod
    private let decode: DecodingMethod
    private let queue: DispatchQueue
    
    init(
        url: URL,
        fileManager: FileManager,
        encode: @escaping EncodingMethod,
        decode: @escaping DecodingMethod,
        observingQueue queue: DispatchQueue = DispatchQueue(label: "com.FilesRepository.workQueue")
    ) throws {
        if !fileManager.fileExists(atPath: url.path) {
            fileManager.createFile(atPath: url.path, contents: nil, attributes: [:])
        }
        self.fileHandler = try FileHandle(forUpdating: url)
        self.encode = encode
        self.decode = decode
        self.queue = queue
    }
    
    deinit {
        try? fileHandler.close()
    }
    
    func observe() -> Observable<[Model]> {
        return .create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.read(into: observer) // Initial read, before any updates came
            let source = self.makeDispatchSource()
            source.setEventHandler {
                guard source.data.contains(.extend) else { return }
                self.read(into: observer)
            }
            source.resume()
            
            return Disposables.create {
                source.cancel()
            }
        }
    }
    
    
    func save(objects: [Model]) -> Single<Void> {
        return .create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            do {
                self.fileHandler.seek(toFileOffset: 0)
                let previousData = self.fileHandler.readDataToEndOfFile()
                let previousObjects = previousData.isEmpty ? [] : (try self.decode(previousData))
                let data = try self.encode(previousObjects + objects)
                self.fileHandler.truncateFile(atOffset: 0)
                self.fileHandler.write(data)
                observer(.success(()))
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    private func read(into observer: AnyObserver<[Model]>) {
        do {
            fileHandler.seek(toFileOffset: 0)
            let data = fileHandler.readDataToEndOfFile()
            let models = data.isEmpty ? [] : (try decode(data))
            observer.onNext(models)
        } catch {
            observer.onError(error)
        }
    }
    
    private func makeDispatchSource() -> DispatchSourceFileSystemObject {
        DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: self.fileHandler.fileDescriptor,
            eventMask: .extend,
            queue: self.queue
        )
    }
}
