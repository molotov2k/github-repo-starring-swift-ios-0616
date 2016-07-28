//
//  GithubAPIClient.swift
//  github-repo-starring-swift
//
//  Created by Haaris Muneer on 6/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class GithubAPIClient {
    
    class func getRepositoriesWithCompletion(completion: (NSArray) -> ()) {
        let urlString = "https://api.github.com/repositories?client_id=\(Secrets.clientID)&client_secret=\(Secrets.clientSecret)"
        let url = NSURL(string: urlString)
        let session = NSURLSession.sharedSession()
        
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        let task = session.dataTaskWithURL(unwrappedURL) { (data, response, error) in
            guard let data = data else { fatalError("Unable to get data \(error?.localizedDescription)") }
            
            if let responseArray = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSArray {
                if let responseArray = responseArray {
                    completion(responseArray)
                }
            }
        }
        task.resume()
    }
    
    
    class func checkIfRepositoryIsStarred(fullName: String, completion: (Bool) -> ()) {
        let urlString = "\(Secrets.githubAPIURL)\(fullName)"
        let url = NSURL(string: urlString)
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = [ "Authorization" : Secrets.token ]
        
        let session = NSURLSession.init(configuration: configuration)
        
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        let task = session.dataTaskWithURL(unwrappedURL) { data, response, error in
            guard let responseValue = response as? NSHTTPURLResponse else {
                assertionFailure("Something went wrong!")
                return
            }
            
            if responseValue.statusCode == 204 {
                completion(true)
            } else if responseValue.statusCode == 404 {
                completion(false)
            } else {
                print("something is wrong: \(responseValue.statusCode)")
            }
        }
        task.resume()
    }
    
    
    class func starRepository(fullName: String, completion: () -> ()) {
        let urlString = "\(Secrets.githubAPIURL)\(fullName)"
        let url  = NSURL(string: urlString)
        
        let session = NSURLSession.sharedSession()
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        
        let request = NSMutableURLRequest(URL: unwrappedURL)
        request.HTTPMethod = "PUT"
        request.addValue("\(Secrets.token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let responseValue  = response as? NSHTTPURLResponse else {
                assertionFailure("Something wring!")
                return
            }
            
            if responseValue.statusCode == 204 {
                completion()
            }
        }
        task.resume()
    }
    
    
    class func unStarRepository(fullName: String, completion: () -> ()) {
        let urlString = "\(Secrets.githubAPIURL)\(fullName)"
        let url  = NSURL(string: urlString)
        
        let session = NSURLSession.sharedSession()
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        
        let request = NSMutableURLRequest(URL: unwrappedURL)
        request.HTTPMethod = "DELETE"
        request.addValue("\(Secrets.token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let responseValue  = response as? NSHTTPURLResponse else {
                assertionFailure("Something wring!")
                return
            }
            
            if responseValue.statusCode == 404 {
                completion()
            }
        }
        task.resume()
    }
    
    
    func toggleStarStatusForRepository(repository: GithubRepository, completion: () -> ()) {
        GithubAPIClient.checkIfRepositoryIsStarred(repository.fullName) { (starred) in
            if starred == true {
                GithubAPIClient.unStarRepository(repository.fullName) { (output) in }
                print("unstarring")
            } else {
                GithubAPIClient.starRepository(repository.fullName) { (output) in }
                print("statting")
            }
        }
        completion()
    }
    
    
}

