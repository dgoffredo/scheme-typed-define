![typed definitions](typed-define.jpg)

scheme-typed-define
===================
syntax for an alternative "define" with type annotations, in Chicken Scheme

Why
---
Mostly I'm playing with macros.  I do like it better than the alternatives,
though, built into Chicken and based off of typed Racket:

    (: string-join ((list-of string) string -> string))

    (define (string-join strings delimiter)
      (conc strings " joined with " delimiter))

I find this nicer:

    (define* (string-join strings delimiter)
      :: (list-of string) string -> string
      (conc string " joined with " delimiter))

It's only syntax, after all.

What
----
A Chicken Scheme module, `typed-define`, that exports syntax for the new form
`define*`, which is just like `define` but optionally accepts a type annotation
and expands to the appropriate `declare` form and then the `define`, together
in a `begin` block.

How
---
There's probably some special thing you have to do to generate the "import"
translation unit from `typed-define.scm` such that its syntax is included.
What I've been doing instead is this:

    (include "typed-define")
    (import typed-define)

More
----
Refer to the comments in the source code.
