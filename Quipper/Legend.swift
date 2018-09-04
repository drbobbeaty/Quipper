//
//  Legend.swift
//  Quipper
//
//  Created by Bob Beaty on 7/23/18.
//  Copyright © 2018 Bob Beaty. All rights reserved.
//

import Foundation

class Legend : Equatable, NSCopying {
	let LCai: Int = 97			// 'a' == 97 in ASCII
	var legend = [Character](repeating: "\0", count: 26)
	
	init(_ cypher: Character, is plain: Character) {
		addCypher(cypher, for: plain)
	}
	
	init(_ dup: Legend) {
		legend = dup.legend
	}
	
	/**
	 This method sets the mapping in this legend for the provided pair of
	 characters: the cypher character and the plain character. This will
	 go into the legend and will be used in all subsequent decodings of
	 cypherwords by this legend.

	 - parameter cypher: The cypher character
	 - parameter plain: The plain character
	 */
	func addCypher(_ cypher: Character, for plain: Character) {
		legend[cypher.lowerCase.asciiValue - LCai] = plain.lowerCase
	}
	
	/**
	 When a mapping in a legend has been seen to be an error, you need a method
	 to 'undo' that mapping so a different modification to the legend cam be
	 tried. This method removes the mapping for the cyphertext character in the
	 legend so it will not be mapped in subsequent applications of this legend
	 to a cypherword.

	 - parameter cypher: The cypher character
	 */
	func removeCypher(_ cypher: Character) {
		legend[cypher.lowerCase.asciiValue - LCai] = "\0"
	}
	
	/**
	 This method returns the plaintext character for the cyphertext character
	 supplied - IF a mapping exists for this cyphertext character. If not, the
	 return value will be '\0', so you need to check on this before you go
	 blindly using it.

	 - parameter cypher: The cypher character.
	 - returns: The plain character for this cypher character, or "\0"
	 */
	func plainForCypher(_ cypher: Character) -> Character {
		let pc = legend[cypher.lowerCase.asciiValue - LCai]
		return (cypher.asciiValue < LCai ? pc.upperCase : pc)
	}
	
	/**
	 This method returns the cyphertext character for the plaintext character
	 supplied - IF a mapping exists for this pairing. If not, the
	 return value will be '\0', so you need to check on this before you go
	 blindly using it.

	 - parameter plain: The cypher character.
	 - returns: The cypher character for this plain character, or "\0"
	 */
	func cypherForPlain(_ plain: Character) -> Character {
		if let i = legend.index(of: plain.lowerCase) {
			let cc = Character(UnicodeScalar(i + LCai)!)
			return (plain.asciiValue < LCai ? cc.upperCase : cc)
		}
		return "\0"
	}
	
	/**
	 There will be times when we want to know if it's possible to take a
	 cypherword and it's possible plaintext and augment our own mapping with
	 the characters in these words without creating an illegal Legend. Examples
	 would be changing the existing mapped characters or create two different
	 plaintext characters for the same cypher character. If it's possible,
	 we'll incorporate the mappings and return YES, if not, nothing it changed
	 and NO is returned.

	 - parameter cyphertet: The cyphertext to use as a sequence of mappings
	 - parameter plaintext: The plaintext to use as a sequence of mappings
	 - returns: True, if the mappings can be incorporated without conflict
	 */
	func incorporate(_ cyphertext: String, as plaintext: String) -> Bool {
		// make sure the lengths are the same - that's silly easy
		guard (cyphertext.count == plaintext.count) else {
			return false
		}
		// get lowercase versions of these inputs
		let ct = cyphertext.lowercased()
		let pt = plaintext.lowercased()
		// make sure the additional mappings don't conflict with what we have
		for (cc, pc) in zip(ct, pt) {
			let cco = cc.asciiValue - LCai
			if (legend[cco] != pc) && (legend[cco] != "\0" || legend.index(of: pc) != nil) {
				return false
			}
		}
		// OK... do the mappings based on this good data - we think
		for (cc, pc) in zip(ct, pt) {
			legend[cc.asciiValue - LCai] = pc
		}
		// ...and all is well at this point
		return true
	}
	
	/**
	 This method takes a cyphertext and attempts to completely decode it into a
	 plaintext using the mapping currently available. If it creates a completely
	 decoded word/phrase, it returns that word. If not, it returns nil. All
	 whitespace and punctuation is simply passed through unchanged.

	 - parameter cyphertext: The cyphertext to decode with the legend
	 - returns: the decoded string, of it's possible
	 */
	func decode(_ cyphertext: String) -> String? {
		var ans = ""
		for cc in cyphertext {
			if cc.isAlpha() {
				let dc = plainForCypher(cc)
				if dc == "\0" {
					return nil
				}
				ans.append(dc)
			} else {
				ans.append(cc)
			}
		}
		return ans
	}
	
	/**
	 This is what we have to implement for NSCopying so that we can copy
	 these with a solid deep-copy.
	 */
	func copy(with zone: NSZone? = nil) -> Any {
		return Legend(self)
	}
	
	/**
	 This is what we have to add for Equatable so that we can make simple
	 comparisons on these legends.
	 */
	static func == (lhs: Legend, rhs: Legend) -> Bool {
		return lhs.legend == rhs.legend
	}

	static func != (lhs: Legend, rhs: Legend) -> Bool {
		return !(lhs == rhs)
	}
}

/**
 This extension adds a few nice things to the Character so that we can more
 easily manipulate it in the Legend.
 */
extension Character {
	func isAlpha() -> Bool {
		return CharacterSet.letters.contains(String(self).unicodeScalars.first!)
	}
	
	var asciiValue: Int {
		get {
			let s = String(self).unicodeScalars
			return Int(s[s.startIndex].value)
		}
	}

	var upperCase: Character {
		get {
			return String(self).uppercased().first!
		}
	}

	var lowerCase: Character {
		get {
			return String(self).lowercased().first!
		}
	}
}
