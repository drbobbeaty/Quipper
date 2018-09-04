//
//  PuzzlePiece.swift
//  Quipper
//
//  Created by Bob Beaty on 7/24/18.
//  Copyright © 2018 Bob Beaty. All rights reserved.
//

import Foundation

class PuzzlePiece : Equatable {
	var cypherword: CypherWord
	var possibles: Set<String>
	
	init(_ cyphertext: String) {
		self.cypherword = CypherWord(cyphertext)
		self.possibles = Set<String>()
	}
	
	/**
	 Return the length of the cypherword for this piece of the puzzle.

	 - returns: The length of the cypherword that's part of the puzzle piece
	 */
	var length: Int {
		get {
			return cypherword.length
		}
	}

	/**
	 This computed ivar returns the number of possible plaintext matches we are
	 currently holding that match in pattern, and length, the cyphertext we
	 have. It's a simple way to see how many possible decodings we know about
	 for this one cypherword.

	 - returns: The number of possible matches for this cypherword puzzle piece
	 */
	var matches: Int {
		get {
			return possibles.count
		}
	}
	
	/**
	 This method uses the provided legend to partially, if not fully, decode the
	 cypherword into plaintext and then check that against all the possible plain
	 text words we know about and returns how many matches there are. This is a
	 good way to see how many, if any, matches there are to the decoding provided
	 by the legend.

	 - parameter legend: The Legend to use to attempt to decode the puzzle piece
	                     and see how many words match this decoding from the list
	                     of possibles.
	 - returns: The number of possible matches when the Legend is applied to the
	            puzzle piece.
	 */
	func countPossibles(for legend: Legend) -> Int {
		guard (possibles.count > 0) && (cypherword.length > 0) else {
			return 0
		}
		var hits = 0
		for p in possibles {
			if cypherword.canMatch(p, with: legend) {
				hits += 1
			}
		}
		return hits
	}
	
	/**
	 This method looks at the supplied plaintext word, and if it's pattern matches
	 the CypherWord we have, then we'll add it to the array of possibles. It's a
	 simple way to populate the list of possible plaintext words for all the
	 pieces in the puzzle.

	 - parameter plaintext: The plaintext to check for the same pattern as the
	                        puzzle piece's cypherword.
	 - returns: True, if the patterns of the letters in the words matches.
	 */
	@discardableResult func isPossible(_ plaintext: String) -> Bool {
		guard (cypherword.length > 0) else {
			return false
		}
		if cypherword.matchesPattern(plaintext) {
			possibles.formUnion([plaintext])
			return true
		}
		return false
	}
	
	/**
	 This method will attempt to drop the provided possible plaintext
	 word from the list of possibles for this piece.

	 - parameter plaintext: The plaintext possible word to drop from the list
	                        of possibles for this puzzle piece.
	 */
	func dropPossible(_ plaintext: String) {
		possibles.subtract([plaintext])
	}
	
	/**
	 This method will clear out all the possible plaintext words for this
	 piece.
	*/
	func clearPossibles() {
		possibles.removeAll()
	}
	
	/**
	 This is what we have to add for Equatable so that we can make simple
	 comparisons on these pieces.
	*/
	static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
		return (lhs.cypherword == rhs.cypherword) && (lhs.possibles == rhs.possibles)
	}
	
	static func != (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
		return !(lhs == rhs)
	}
}

