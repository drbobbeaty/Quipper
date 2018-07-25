# Quipper

The standard CryptoQuip, as it appears in the comics, is a simple substitution
cypher where one character of the solution is provided, and it's up to the player to
figure out the rest from the provided cyphertext and the clue. It's a fun little
puzzle to play, but that doesn't stop a more _analytical_ approach.

This project is about a few different attacks on solving the general CryptoQuip
puzzle in as short a time as possible. There are other versions of this same
attack, and there are several different attack schemes. This just happens to be
the fastest we've found.

This version is in Swift 4.2, and has been made as quick as that language
can perform. It is primarily a benchmark for the language.

## Usage

When you run the app, it allows you to input a cyphertext, and the one,
known letter of the solution. Then you hit the 'Solve' button, and it looks
at all the words it knows and sees what the solution is.
