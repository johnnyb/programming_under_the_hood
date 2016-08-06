* Programming Under the Hood

This project is a book - it is intended to be the next edition of the popular assembly language book "Programming from the Ground Up" (PGU).

PGU has been a popular assembly language book for well over a decade, and continues to sell well.  However, it suffers from a number of problems:

1) Poor editing - the original editor fell ill during the process, so the book is, essentially, unedited.  I have even found a place where a paragraph stops mid-sentence.  This needs fixing.

2) 64-bit support - the book focuses on 32-bit.  32 bit programming will probably continue to be the focus, but there certainly needs to be some content added for 64-bit programming.

3) Less "intro"-ish.  Many people used this book, but few used it as their first programming book.  I plan on keeping the explanations simple, but I'm not going to pretend the user has never seen code before.

4) More details on other under-the-hood topics.  While this will still be a full assembly language introduction, there are several things that can also be known that assembly language makes easier.  For instance, we will probably add sections on various memory management schemes, C++ object layouts and virtual tables, and other fun things.  This allows for a continual addition of interesting items through the years, widens the audience, and gives more reason for actually learning assembly language.

5) Conversion from Docbook XML to LaTeX.  I was a big fan of XML and thought it showed a lot of promise.  I wrote the original book using Docbook XML and DSSSL.  I thought that both were great systems (though DSSSL had some problems, I thought that it was a good overall plan).  However, I'm not sure that OpenJade (the DSSSL processor) has had a release since the last release of PGU!  It certainly seems to be a dead project.  However, LaTeX is still in active use, and it is relatively easy to find TeXnicians when you need them.  Therefore, as I have converted the rest of my publishing to LaTeX, it is time to convert this book.  This will be the first big project in the process of releasing the book.  This is especially hard because I used a lot of little-used XML features to write the book, many of which are not supported in standard XML-reading libraries!  Anyway, we will see how it goes.

I am probably also going to try to integrate some of my IBM DeveloperWorks articles into the mix.  We will see which ones are worth porting over.  I would also like some more system-level instructions covered, but don't know if we will get to it.

The goal is for this to be published by BP Learning (my company) in the "Programmer's Toolbox" series.  Current publications in that series includes "New Programmers Start Here" and "Building Scalable Web Applications Using the Cloud".  The book will have a similar cover and illustration to those.

Not all of BP Learning's books are open-source, but this one will be.
