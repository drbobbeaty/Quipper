//
//  MrBig.swift
//  Quipper
//
//  Created by Bob Beaty on 7/24/18.
//  Copyright © 2018 Bob Beaty. All rights reserved.
//

import Foundation
import AppKit

@objc class MrBig: NSObject {
	@IBOutlet weak var cyphertextLine: NSTextField!
	@IBOutlet weak var cypherChar: NSPopUpButton!
	@IBOutlet weak var plainChar: NSPopUpButton!
	@IBOutlet weak var plaintextLine: NSTextField!

	var wordList = [String]()
	var patterns = [String: [String]]()
	
	override init() {
		super.init()
		let fileURL = Bundle.main.url(forResource:"words", withExtension: nil)!
		let body = try! String.init(contentsOf: fileURL)
		wordList = body.components(separatedBy: "\n")
		NSLog("Successfully read in \(wordList.count) words from file")
	}
	
	deinit {
		wordList.removeAll()
		patterns.removeAll()
	}
	
	/**
	 This action is typically the target of a button the user will press on when
	 they want us to solve the provided puzzle. It's going to create a Quip with
	 the cyphertext and the initial start at a legend and then ask it to solve the
	 puzzle. When it's done, we'll pick off the solutions and see what we see.
	 */
	@IBAction func decode(_ sender: AnyObject) {
		// get values from the UI
		var ct = self.cyphertextLine.stringValue
		var cs = self.cypherChar.titleOfSelectedItem!
		var ps = self.plainChar.titleOfSelectedItem!
		// default to the test values if the cyphertext is missing
		if ct.isEmpty {
			ct = "Fict O ncc bivteclnbklzn O lcpji ukl pt vzglcddp"
			cs = "b"
			ps = "t"
			self.cyphertextLine.stringValue = ct
			self.cypherChar.selectItem(withTitle: cs.uppercased())
			self.plainChar.selectItem(withTitle: ps.uppercased())
		}
		solve(ct, where: cs[cs.startIndex], equals: ps[ps.startIndex])
	}
	
	/**
	 This method runs a simple test decoding so that we can be sure that things
	 are working properly. It's going to use the cyphertext:
	   Fict O ncc bivteclnbklzn O lcpji ukl pt vzglcddp
	 with the initial legend:
	   b = t
	 and *should* solve to the plaintext:
	   When I see thunderstorms I reach for an umbrella
	 If not, then we're in trouble.
	*/
	@IBAction func testDecode(_ sender: AnyObject) {
		solve("Fict O ncc bivteclnbklzn O lcpji ukl pt vzglcddp", where:"b", equals:"t")
	}
	
	/**
	 This method is what really runs the decoder, and it takes the cyphertext
	 string as well as the initial part of the legend, and will load up the
	 Quip and have it do it's thing, placing the solution in the text field
	 when it's done. Pretty simple. I just needed a single method to do this.

	 - parameter cyphertext: The source cyphertext to decode
	 - parameter cypherChar: The cypher character that's part of the hint
	 - parameter plainChar: The plain character that's part of the hint
	 */
	func solve(_ cyphertext: String, where cypherChar: Character, equals plainChar: Character) {
		NSLog("Solving puzzle: '\(cyphertext)' where \(cypherChar)=\(plainChar)")
		let qqq = Quip(cyphertext, where: cypherChar, is: plainChar)
		qqq.attemptWordBlockAttack(wordList)
		if qqq.solutions.count > 0 {
			self.plaintextLine.stringValue = qqq.solutions[0]
		}
	}
}
