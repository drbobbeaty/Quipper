//
//  CypherWord.swift
//  Quipper
//
//  Created by Bob Beaty on 7/23/18.
//  Copyright © 2018 Bob Beaty. All rights reserved.
//

import Foundation

class CypherWord : Equatable {
	var cyphertext = ""
	var cypherSize = 0
	var cypherChars = [Character]()
	var cypherCount = 0
	var cypherPattern = ""

	init(_ cyphertext: String) {
		self.cyphertext = cyphertext
		self.cypherSize = cyphertext.count
		self.cypherPattern = cyphertext.pattern
	}
	
	/**
	 Return the length of the cypherword itself.

	 - returns: length of the cypherword
	 */
	var length: Int {
		get {
			return cypherSize
		}
	}
	
	/**
	 One of the initial tests of a plaintext word is to see if the pattern of
	 characters matches the cyphertext. If the pattern doesn't match, then the
	 decoded text can't possibly match, either. This method will look at the
	 pattern of characters in the cyphertext and compare it to the pattern in
	 the argument and if they match, will return true.

	 - parameter plaintext: A plaintext word to see if it matches the pattern
	                        of the cypherword
	 - returns: True if the pattern of the two words matches
	 */
	func matchesPattern(_ plaintext: String) -> Bool {
		return (cypherSize == plaintext.count) && (cypherSize > 0) &&
			(cypherPattern == plaintext.pattern)
	}
	
	/**
	 This method will use the provided Legend and map the cyphertext into a
	 plaintext string and then see if the resulting word COULD BE the plaintext.
	 This is not to say that the word is completely decoded - only that those
	 characters that are decoded match the characters in the plaintext.

	 - parameter plaintext: A possible plaintext version of the cypherword
	 - parameter legend: The decoding legend (key) for the mapping
	 - returns: True, if the cypherword maps to the plaintext with the legend
	 */
	func canMatch(_ plaintext: String, with legend: Legend) -> Bool {
		guard matchesPattern(plaintext) else {
			return false
		}
		// decode what we can, and look for obvious failures
		for (pc, cc) in zip(plaintext, cyphertext) {
			let dc = legend.plainForCypher(cc)
			if (dc != "\0") && (dc != pc){
				return false
			}
		}
		return true
	}
	
	/**
	 This method returns true if, and only if, the Legend applied to this
	 cyphertext results in the plaintext <b>exactly</b>. This means that there
	 are NO characters that aren't properly decoded in the cyphertext. If this
	 method returns true, then can_match? will be true, but the reverse is not
	 necessarily true.

	 - parameter plaintext: A possible plaintext version of the cypherword
	 - parameter legend: The decoding legend (key) for the mapping
	 - returns: True, if the cypherword maps to the plaintext with the legend
	 */
	func doesMatch(_ plaintext: String, with legend: Legend) -> Bool {
		guard matchesPattern(plaintext) else {
			return false
		}
		// decode what we can, and look for obvious failures
		for (pc, cc) in zip(plaintext, cyphertext) {
			let dc = legend.plainForCypher(cc)
			if (dc == "\0") || (dc != pc){
				return false
			}
		}
		return true
	}
	
	/**
	 This method takes the Legend and applies it to the cyphertext and IF it
	 creates a completely decoded word, it returns that word. If not, it
	 returns nil. This is very similar to decodes_to? but it returns the word
	 it decodes to.

	 - parameter legend: The decoding legend (key) for the mapping
	 - returns: Decoded string for the cypherword
	 */
	func decode(with legend: Legend) -> String? {
		guard (cypherSize > 0) else {
			return nil
		}
		return legend.decode(cyphertext)
	}
	
	/**
	 This is what we have to add for Equatable so that we can make simple
	 comparisons on these cypher words.
	 */
	static func == (lhs: CypherWord, rhs: CypherWord) -> Bool {
		return lhs.cyphertext == rhs.cyphertext
	}
	
	static func != (lhs: CypherWord, rhs: CypherWord) -> Bool {
		return !(lhs == rhs)
	}
}

extension String {
	/**
	 Attributes of a string that return a string that is the pattern of that
	 word where the values are the index of the character. This is a simple
	 baseline pattern generator for the words so they are comparable.

	```
	   => "see".pattern
	   "abb"
	   => "rabbit".pattern
	   "abccef"
	```
	 */
	var pattern: String {
		get {
			let ascii: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
			var ans = ""
			for c in self {
				ans.append(ascii[self.index(of: c)!.encodedOffset])
			}
			return ans
		}
	}
}
