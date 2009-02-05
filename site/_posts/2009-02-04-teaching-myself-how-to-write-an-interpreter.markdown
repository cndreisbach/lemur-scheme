---
layout: post
title: Teaching Myself How to Write an Interpreter
---

For this project, I am going to implement a Scheme interpreter, and hopefully a compiler, for the Java Virtual Machine. The closest I've come to anything like this is simple parsing of arithmetic expressions and compiling them into assembly code. I have no real idea of how to write an interpreter, which is why I'm doing it.

Part of this project is teaching myself how to write an interpreter and a compiler. I've spent a few days researching how to do this, and I've come up with a solid list of references:

### Books

* [Practical Ruby Projects](http://apress.com/book/view/9781590599112) by Topher Cyll - has a good chapter on implementing Scheme in Ruby
* [Programming Languages: Application and Interpretation](http://www.cs.brown.edu/~sk/Publications/Books/ProgLangs/2007-04-26/) by Shriram Krishnamurthi
* [Modern Compiler Implementation in Java](http://www.cs.princeton.edu/~appel/modern/java/) by Andrew W. Appel

### Online articles and reference

* [How to Build an Interpreter in Java](http://www.javaworld.com/javaworld/jw-05-1997/jw-05-indepth.html) by Chuck McManis
* [Programming Languages for the JVM](http://www.is-research.de/info/vmlanguages/) - looking at other people's implementations of non-Scheme languages could certainly help.
* [Write Yourself a Scheme in 48 Hours](http://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours) by Jonathan Tang - while this uses Haskell to build the interpreter, it's a good reference to follow.
* [An Incremental Approach to Compiler Construction](http://lambda-the-ultimate.org/node/1752) by Abdulaziz Ghuloum
* [JScheme: Design Decisions](http://norvig.com/jscheme-design.html) by Peter Norvig - while I am not going to look at the code for Norvig's Scheme until after this project is done, his design decisions document is a good read.

I've got a set of readings, but now I need a set of assignments for myself. My planned mode of attack is to:

* First, write a minimal Scheme interpreter in JRuby. It doesn't have to meet much of a standard, but should be a good proof of concept. I'm familiar with Ruby and it's dynamically typed, which helps. Technically, this will be an interpreter running on the JVM, but the point is to write this in a statically typed language such as Java or Scala.
* Next, write the same interpreter in Scala. Scala's combinator parsing lets me eliminate the work of a real lexer, as I can write out my Scheme specification in a format very near Extended Backus-Naur Form. Combinator parsers are slow, but that's OK for now.
* Optional: rewrite my parser using JFlex to make a lexer first.
* Start trying to meet the standard. There are going to be some tricky concepts in here. Tail-call recursion and the full Scheme numerical stack aren't going to be easy. I'll decide what order to tackle tasks in when I get here.
* Build a compiler.

I'll be updating this blog with reports as I move forward.
