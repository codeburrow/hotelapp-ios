//
//  HotelAppTests.swift
//  HotelAppTests
//
//  Created by Konstantinos Loutas on 10/07/16.
//  Copyright © 2016 Constantine Lutas. All rights reserved.
//

import XCTest
import Alamofire
@testable import HotelApp

class HotelAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestRemoteNotification() {
        let expect = expectation(description: "waitForWebService")
        let notifRequestUrl = "https://hotelapp-web.herokuapp.com/push"
        Alamofire.request(notifRequestUrl).responseString { (response) in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSerialiseRemoteNotificationRequestResponse() {
        let expect = expectation(description: "serialiseResponse")
        let notifRequestUrl = "https://hotelapp-web.herokuapp.com/push"
        var serverResponseString: String?
        Alamofire.request(notifRequestUrl).responseString { (response) in
            if let responseString = response.result.value {
                serverResponseString = responseString
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(serverResponseString!, "Successful Delivery!\n")
    }
    
}
