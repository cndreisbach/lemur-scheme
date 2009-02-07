---
layout: post
title: Closure Assumption Possibly Wrong
---
In my last post, I made this assumption:

> The closure's only supposed to capture the environment at the time it was created. Defining `x` later shouldn't let `fx` access that new variable.

It ends up that I'm probably wrong about that, at least according to MzScheme:

<pre><code>cnixon:~$ mzscheme 
Welcome to MzScheme v372 [3m], Copyright (c) 2004-2007 PLT Scheme Inc.
> (define fx (lambda () x))
> (fx)
reference to undefined identifier: x
> (define x 1)
> (fx)
1
</code></pre>

Chicken Scheme backs me up on this. Ruby, on the other hand, behaves differently:

<pre><code>cnixon:~$ irb
irb(main):001:0&gt; fx = lambda { x }
=&gt; #&lt;Proc:0x010b15d4@(irb):1&gt;
irb(main):002:0&gt; fx
=&gt; #&lt;Proc:0x010b15d4@(irb):1&gt;
irb(main):003:0&gt; fx.call
NameError: undefined local variable or method `x' for main:Object
	from (irb):1
	from (irb):3:in `call'
	from (irb):3
irb(main):004:0&gt; x = 1
=&gt; 1
irb(main):005:0&gt; fx.call
NameError: undefined local variable or method `x' for main:Object
	from (irb):1
	from (irb):5:in `call'
	from (irb):5
</code></pre>

