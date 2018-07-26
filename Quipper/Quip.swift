//
//  Quip.swift
//  Quipper
//
//  Created by Bob Beaty on 7/24/18.
//  Copyright © 2018 Bob Beaty. All rights reserved.
//

import Foundation

class Quip {
	var cyphertext = ""
	var cypherChar: Character
	var plainChar: Character
	var legend: Legend
	var pieces = [PuzzlePiece]()
	var solutions = [String]()
	
	init(_ cyphertext: String, where cypherchar: Character, is plainchar: Character) {
		self.cyphertext = cyphertext
		self.cypherChar = cypherchar
		self.plainChar = plainchar
		self.legend = Legend(cypherchar, is: plainchar)
		let all = cyphertext.split(separator: " ")
		self.pieces = Array(Set(all)).map { PuzzlePiece(String($0)) }
	}

	/*!
	 This is the entry point for attempting the "Word Block" attack on the
	 cyphertext. The idea is that we start with the initial legend, and then
	 for each plaintext word in the first cypherword that matches the legend,
	 we add those keys not in the legend, but supplied by the plaintext to
	 the legend, and then try the next cypherword in the same manner.
	
	 There will be quite a few 'passes' in this attack plan, but hopefully not
	 nearly as many as a character-based scheme.
	
	 If this attack results in a successful decoding of the cyphertext, this
	 method will return true, otherwise, it will return false.
	 */
	func attemptWordBlockAttack(_ words: [String]) {
		NSLog("Clearing out all old data for the attack...")
		// clear everything out that might be left-over
		solutions.removeAll()
		pieces.forEach { $0.clearPossibles() }
		// takes the list of words, and see which ones match
		words.forEach { w in pieces.forEach { p in p.isPossible(w) } }
		// sort in place, by the number of matches
		pieces.sort { $0.matches < $1.matches }
		// ...and run the attach on the least matches
		NSLog("List of Possibles:")
		for p in pieces {
			NSLog("  ... \(p.cypherword.cyphertext) :: \(p.possibles.count)")
		}
		NSLog("Starting the word block attack...")
		let begin = NSDate().timeIntervalSince1970 * 1000
		doWordBlockAttack(at: 0, with: legend)
		NSLog("\(solutions.count) Solution(s) took \(NSDate().timeIntervalSince1970 * 1000 - begin) msec")
	}
	
	/*!
	This is the recursive entry point for attempting the "Word Block" attack
	 on the cyphertext starting at the 'index'th word in the quip. The idea is
	 that we start with the provided legend, and then for each plaintext word
	 in the 'index'ed cypherword that matches the legend, we add those keys not
	 in the legend, but supplied by the plaintext to the legend, and then try
	 the next cypherword in the same manner.
	
	 If this attack results in a successful decoding of the cyphertext, this
	 method will return true, otherwise, it will return false.
	 */
	@discardableResult private func doWordBlockAttack(at idx: Int, with key: Legend) -> Bool {
		let p = pieces[idx]
		let cw = p.cypherword
		NSLog("working on word: \(idx) [\(cw.cyphertext)] - \(p.possibles.count) possible matches")
		p.possibles.forEach { pt in
			var solved = false
			if cw.canMatch(pt, with: key) {
				// good! Now let's see if we are done with all the words
				if idx == pieces.count - 1 {
					// make sure we can really decode the last word
					if key.incorporate(cw.cyphertext, as: pt) {
						// if it's good, add the solution to the list
						if let dec = key.decode(cyphertext) {
							solutions.append(dec)
							solved = true
						}
					}
				} else {
					//
					let nextKey = key.copy() as! Legend
					if nextKey.incorporate(cw.cyphertext, as: pt) {
						solved = doWordBlockAttack(at: idx + 1, with: nextKey)
					}
				}
				if solved { return  }
			}
		}
		return solutions.count > 0
	}
}
