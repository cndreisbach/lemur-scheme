require File.dirname(__FILE__) + '/lib/lemur'
include Lemur
lemur = Interpreter.new
lemur.eval %Q{(! (! (ruby File) open "#{__FILE__}") each (lambda (line) (print line)))}
