# svggames

Create SVG Game Boards in Python and Perl

# Description

I have a CNC router and the g-code it needs uses SVG as source files.  I wanted to carve out some wooden game boards and then stain them.   Python and Perl scripts using the SVG module seemed the appropriate choice.

There are several "not best practices" in code that I know I"m using, such as ignoring the PEP standards.   I'll fix that stuff up later.   

# Instructions

1. Choose a script and run it.  All of them have help that will show you how to create files of your choice.

2. You can redirect the output to a file (it is simply SVG text).  ie:  perl 9mensmorris.pl > 9mens.svg

3. You may need to adjust scaling as it's designed to print on a specific size of wooden board, and that might not match your printer.    Luckily, SVG is a scalable vector graphic so scaling shouldn't be a problem.   Scale either through your printer software, or in the code itself.





