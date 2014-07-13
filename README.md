explicit-return
===============

Have your methods return nil by default.

    module Foo
    
        include ExplicitReturn

        def self.bar
            123
        end

        def self.baz
            return explicit 123
        end

    end

    foo.bar #=> nil
    foo.baz #=> 123


Why?
====

Implicit returns are one of Ruby's nicest features.  So why throw them out the window?.  Let's say, one day I sit down with a headache and hack up the following.

    def self.delete_3(array)
        array.each{|e|
            array.delete(e) if e == 3
        }
    end

    #somewhere else

    no_three_array = Foo.delete_3([1,2,3,4,5])

A few months later someone else with a slightly more lucid state of mind comes along and decides to fix my method.

    def self.delete_3(array)
        array.delete(3)
    end

The problem is that now no_three_array #=> 3.  One might argue that the real problem is lack of documentation, counter-intuitive method naming, TDD, etc.  ExplicitReturn does not pupport to be a big picture solution, rather a simple saftey guard to avoid shooting yourself in the foot.

How?
====

Upon inclusion of the ExplicitReturn module, ExplicitReturn will listen to new definintions of methods and will wrap them so that it can check the results and esure they are ExplicitResult objects.  ExplicitResult objects are created with the explicit() method.  Hence:

    return explicit my_obj
    #can be rewritten
    return explicit(my_obj)

