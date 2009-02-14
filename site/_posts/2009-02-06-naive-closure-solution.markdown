---
layout: post
title: A Naive Solution for Closures
---

I was reading _[Practical Ruby Projects](http://apress.com/book/view/9781590599112)_ tonight and working on implementing lambdas when I found an example of closures not working right:

{% highlight scheme %}
(define fx (lambda () x))
(fx) ; ERROR: No value for symbol x
(define x 1)
(fx) ; 1
{% endhighlight %}

The closure's only supposed to capture the environment at the time it was created. Defining `x` later shouldn't let `fx` access that new variable. _PRP_ says that most ways to fix this problem are "a little tricky" and gives the idea of creating a new environment for each line of code evaluated in the same scope.

I solved this a different way, but it was simple enough that I'm afraid it's naive and prone to being busted.

{% highlight ruby %}
module Lemur

  class Env
    def copy
      Env.new(@parent, @defs.clone)
    end
  end

  class Lambda
    def initialize(env, forms, params, *code)
      # was this: @env = env
      @env = env.copy
      @forms = forms
      @params = params.to_array
      @code = code
    end
  end
  
end
{% endhighlight %}

If anyone out there has an idea of where the bugs in this are (or thinks it's a good solution), drop me [an email](mailto:crnixon@gmail.com) or leave a comment.