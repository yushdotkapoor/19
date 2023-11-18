//
//  StorageManager.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation
import Firebase
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()

    private init() {}

    private let storage = Storage.storage().reference()

    public typealias StorageCompletion = (Result<String, Error>) -> Void
    public typealias DownloadCompletion = (Result<Data, Error>) -> Void

    public func uploadPhoto(with data: Data, fileName: String, completion: @escaping StorageCompletion) {
        storage.child(fileName).putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture \(error!)")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            self?.storage.child(fileName).downloadURL(completion: { url, error in
                guard let url = url else {
                    print(fileName)
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func deletePhoto(fileName: String, completion: @escaping StorageCompletion) {
        storage.child(fileName).delete { error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
        }
        completion(.success(""))
    }
    
    

    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
        case failedToDelete
    }

    public func downloadURL(for fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(fileName)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                print("\(fileName) \(error!.localizedDescription)")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }
}
