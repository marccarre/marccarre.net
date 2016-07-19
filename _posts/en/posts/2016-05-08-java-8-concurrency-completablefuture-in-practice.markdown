---
layout: post
title: "Java 8 Concurrency - CompletableFuture in practice"
name: java-8-concurrency-completablefuture-in-practice
date: 2016-05-08 18:38
categories: 
- java
- concurrency
javascript: true
---

With [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) (and its interface, [`CompletionStage<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletionStage.html)), Java 8 finally brings the concept of *promises* to Java.

Promises are the asynchronous alter ego of (synchronous) functions, and like functions, they can:

- return values -- or more accurately, *become fulfilled* by a value,
- throw exceptions -- or more accurately, *complete* with an exception,
- be combined to form a chain, a tree or a graph of operations.

In this article, I will show, using various examples, how to best use `CompletableFuture` to leverage the full potential of promises.

---------------

# Table of Contents
{:.no_toc}
* Table of Contents will appear here.
{:toc}

---------------

# <span style="text-decoration: underline;">Example</span>: basic chaining

Let's first consider the below computation, assuming each operation is expensive (and therefore takes a noticeable amount of time): 

![r=(x+1)+y](/assets/img/java-8-concurrency-completablefuture-in-practice/call_tree.png "Computation tree: r=(x+1)+y")
{: .text-center}

and compare classic, synchronous function calls with asynchronous promises:

{% include collapsible_gist.html id="SynchronousVsAsynchronous" gist_id="b5a5f8c4499a5f3c15e4893d3027bd55" %}

As you could see:

- the synchronous version took **7 seconds**, while
- the asynchronous version took **5 seconds**.

Indeed, if you look again at the tree representing what we are computing here, you immediately realise that `x+1` and `y` can be calculated in parallel, before they are added together to form the final result.
This is the power of asynchronous computations.

---------------

**WARNING**: <br />
Code examples in this article include calls to [`CompletableFuture.get`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#get--) which blocks the main thread and waits for the `CompletableFuture<T>` to finish. I do it to illustrate the behaviour of [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) more conveniently, but this is something you should *avoid* as much as possible in your production code. <br />Ideally, you should chain futures as much as you can (see below), be asynchronous "all the way", and never wait, especially *not* in your main thread. <br />
If you *really* have to wait, consider setting a timeout with [this overload of `CompletableFuture.get`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#get-long-java.util.concurrent.TimeUnit-) and wait in a background thread to avoid blocking your entire application.
[`CompletableFuture.getNow`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#getNow-T-) can also be used and allows you to provide a default value if the future hasn't completed yet. This is useful when your application cannot afford to wait any longer (e.g. when you need to meet a SLA even though a connection to a downstream system has timed out). <br />
**Never**, *ever* "busy poll" in a loop using [`isDone`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#isDone--) or be ready to face the consequences: 100% CPU usage doing... nothing!

---------------

# `CompletableFuture<T>`'s API

The [`supplyAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#supplyAsync-java.util.function.Supplier-), [`thenApply`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenApply-java.util.function.Function-) and [`thenCombine`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenCombine-java.util.concurrent.CompletionStage-java.util.function.BiFunction-) methods used in the above example can be daunting at first, and it may not be immediately clear how to use [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) with its total of 59 methods!

However, if you look at the various functional abstractions available in Java 8, you will see that there is a direct correspondance between these and [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)'s methods, terminology-wise:


## Start asynchronous operations

Indeed, you can start an asynchronous operation either: 

* using a [`Runnable`](https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html) with [`runAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#runAsync-java.lang.Runnable-), or 
* using a [`Supplier`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Supplier.html) with [`supplyAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#supplyAsync-java.util.function.Supplier-):

|---------------------------------------------------------------------------------------------+---------------------+---------------------------------+-------------------------------------------------------+---------------------------|
| Functional abstraction                                                                      | Operation           | Equivalent synchronous function | Start asynchronous operation with                     | Resulting promise         |
|---------------------------------------------------------------------------------------------+---------------------+---------------------------------+-------------------------------------------------------+---------------------------|
| [`Runnable`](https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html)             | `void run();`       | `void procedure();`             | `CompletableFuture.runAsync(() -> runnable.run())`    | `CompletableFuture<Void>` |
| [`Supplier<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Supplier.html) | `T get();`          | `T getter();`                   | `CompletableFuture.supplyAsync(() -> supplier.get())` | `CompletableFuture<T>`    |
|---------------------------------------------------------------------------------------------+---------------------+---------------------------------+-------------------------------------------------------+---------------------------|
{: .table .table-striped .table-bordered .table-condensed}


## Chain asynchronous operations

Similarly, you can chain asynchronous operations either: 

* using a [`Runnable`](https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html) with [`thenRun`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenRun-java.lang.Runnable-), or 
* using a [`Consumer`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Consumer.html) with [`thenAccept`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenAccept-java.util.function.Consumer-), or 
* using a [`Function`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Function.html) with [`thenApply`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenApply-java.util.function.Function-):

|-----------------------------------------------------------------------------------------------+---------------------+---------------------------------+----------------------------------------+---------------------------|
| Functional abstraction                                                                        | Operation           | Equivalent synchronous function | Chain asynchronous operation with      | Resulting promise         |
|-----------------------------------------------------------------------------------------------+---------------------+---------------------------------+----------------------------------------+---------------------------|
| [`Runnable`](https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html)               | `void run();`       | `void procedure();`             | `.thenRun(() -> runnable.run())`       | `CompletableFuture<Void>` |
| [`Consumer<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Consumer.html)   | `void accept(T t);` | `void setter(T t);`             | `.thenAccept(t -> consumer.accept(t))` | `CompletableFuture<Void>` |
| [`Function<T,R>`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Function.html) | `R apply(T t);`     | `R function(T t);`              | `.thenApply(t -> function.apply(t))`   | `CompletableFuture<R>`    |
|-----------------------------------------------------------------------------------------------+---------------------+---------------------------------+----------------------------------------+---------------------------|
{: .table .table-striped .table-bordered .table-condensed}


Chaining `CompletableFuture`s effectively is equivalent to attaching callbacks to the event "my future completed".
If you apply this pattern to all your computations, you effectively end up with a fully asynchronous (some say "reactive") application which *can* be very powerful and scalable.
 

## `Async` vs. non-`Async` methods

As per the [Javadoc](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html), you can fully control where the various operations are run:

> * Actions supplied for dependent completions of *non-async* methods may be performed by the thread that completes the current `CompletableFuture`, or by any other caller of a completion method.
> * All *async* methods without an explicit `Executor` argument are performed using the [`ForkJoinPool.commonPool()`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ForkJoinPool.html#commonPool--) (unless it does not support a parallelism level of at least two, in which case, a new `Thread` is created to run each task).

And you can therefore also provide a specific `Executor` to all the `Async` methods.

Here is the full listing of `Async` and non-`Async` methods returning a `CompletableFuture`:

|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Non-`Async` method                                                                                                                                                                             | `Async` method                                                                                                                                                                                         |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`acceptEither`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#acceptEither-java.util.concurrent.CompletionStage-java.util.function.Consumer-)         | [`acceptEitherAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#acceptEitherAsync-java.util.concurrent.CompletionStage-java.util.function.Consumer-)       |
| [`allOf`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#allOf-java.util.concurrent.CompletableFuture...-) (waits for all futures to complete)          | N/A                                                                                                                                                                                                    |
| [`anyOf`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#anyOf-java.util.concurrent.CompletableFuture...-) (waits for any future to complete)           | N/A                                                                                                                                                                                                    |
| [`applyToEither`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#applyToEither-java.util.concurrent.CompletionStage-java.util.function.Function-)       | [`applyToEitherAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#applyToEitherAsync-java.util.concurrent.CompletionStage-java.util.function.Function-)     |
| [`completedFuture`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#completedFuture-U-) (converts a value in a future already completed with this value) | N/A                                                                                                                                                                                                    |
| [`exceptionally`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#exceptionally-java.util.function.Function-) (handles an exception)                     | N/A                                                                                                                                                                                                    |
| [`handle`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#handle-java.util.function.BiFunction-)                                                        | [`handleAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#handleAsync-java.util.function.BiFunction-)                                                      |
| [`runAfterBoth`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#runAfterBoth-java.util.concurrent.CompletionStage-java.lang.Runnable-)                  | [`runAfterBothAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#runAfterBothAsync-java.util.concurrent.CompletionStage-java.lang.Runnable-)                |
| [`runAfterEither`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#runAfterEither-java.util.concurrent.CompletionStage-java.lang.Runnable-)              | [`runAfterEitherAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#runAfterEitherAsync-java.util.concurrent.CompletionStage-java.lang.Runnable-)            |
| N/A                                                                                                                                                                                            | [`runAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#runAsync-java.lang.Runnable-) (initialises a concurrent operation)                                  |
| N/A                                                                                                                                                                                            | [`supplyAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#supplyAsync-java.util.function.Supplier-) (initialises a concurrent operation)                   |
| [`thenAccept`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenAccept-java.util.function.Consumer-)                                                  | [`thenAcceptAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenAcceptAsync-java.util.function.Consumer-)                                                |
| [`thenAcceptBoth`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenAcceptBoth-java.util.concurrent.CompletionStage-java.util.function.BiConsumer-)   | [`thenAcceptBothAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenAcceptBothAsync-java.util.concurrent.CompletionStage-java.util.function.BiConsumer-) |
| [`thenApply`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenApply-java.util.function.Function-)                                                    | [`thenApplyAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenApplyAsync-java.util.function.Function-)                                                  |
| [`thenCombine`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenCombine-java.util.concurrent.CompletionStage-java.util.function.BiFunction-)         | [`thenCombineAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenCombineAsync-java.util.concurrent.CompletionStage-java.util.function.BiFunction-)       |
| [`thenCompose`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenCompose-java.util.function.Function-)                                                | [`thenComposeAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenComposeAsync-java.util.function.Function-)                                              |
| [`thenRun`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenRun-java.lang.Runnable-)                                                                 | [`thenRunAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenRunAsync-java.lang.Runnable-)                                                               |
| [`whenComplete`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#whenComplete-java.util.function.BiConsumer-)                                            | [`whenCompleteAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#whenCompleteAsync-java.util.function.BiConsumer-)                                          |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{: .table .table-striped .table-bordered .table-condensed}

---------------

# Error handling

If you do anything worth doing asynchronously -- complex distributed computation, network I/O with distant, potentially slow machines, etc. -- chances are you code can (and will!) throw exceptions, so it is logical and critical to discuss how one would handle these asynchronously.

In the following paragraphs, we will look at what happens when a future throws an exception, and various ways to handle these:

* handle and return a default or error value
* handle and return a transformed future
* handle and propagate the exception


## <span style="text-decoration: underline;">Example</span>: when a future throws an exception

Let's first see what happens if you call [`get`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#get--) on a future which threw an exception:

{% include collapsible_gist.html id="AsynchronousException" gist_id="2439456da4b63dfb0c2e931ce1204b01" %}

As you can see in the above code example, 

* the future completes with an exception -- `isCompletedExceptionally()` returns `true`
* calling `get` re-throws the original exception wrapped in an `ExecutionException` -- the original exception being still accessible via `getCause`.


## <span style="text-decoration: underline;">Example</span>: handle exception and return a default or error value

Depending on what you are doing, you may want to return a default or error value, e.g.: `-1` for a computation supposed to return only positive values.
You can achieve this asynchronously using [`exceptionally`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#exceptionally-java.util.function.Function-) and passing a function which converts from a `Throwable` to your default / error value.

{% include collapsible_gist.html id="AsynchronousExceptionsHandlingWithExceptionally" gist_id="63e07c3952f31e6294f71d06e68de803" %}

Note that, given the exception has been handled, `isCompletedExceptionally()` now returns `false`.


## <span style="text-decoration: underline;">Example</span>: handle exception and return a transformed future

Alternatively, you may want to combine a transformation for both the normal case and the error case.
For example, if you are writing a web service, you could return an object representing a HTTP response with either:

* status code `200`/`OK` and the expected result, or
* status code `500`/`Internal Server Error` and details on the error.

You can achieve this asynchronously using [`handle`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#handle-java.util.function.BiFunction-) and passing a function which converts: 

* from your original type and a `Throwable`, 
* to your new type.

{% include collapsible_gist.html id="AsynchronousExceptionsHandlingWithHandle" gist_id="8d73763de4c3835d06659178f4c842b1" %}

Note that, given the exception has been handled here too, `isCompletedExceptionally()` returns `false`.


## <span style="text-decoration: underline;">Example</span>: handle exception and propagate the exception

Finally, you may want to run some arbitrary code for both the normal case and the error case, e.g. to release some resource, to update some state, to log details, etc. but still either return the computed result or propagate the exception thrown.
This is possible with [`whenComplete`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#whenComplete-java.util.function.BiConsumer-).

{% include collapsible_gist.html id="AsynchronousExceptionsHandlingWithWhenComplete" gist_id="360142deeb4dd47906d0773b9f7956c2" %}

---------------

# Advanced usage

## <span style="text-decoration: underline;">Example</span>: long compute vs. slow store

In this example, let's consider an expensive computation to perform. Given it is expensive and its result can be re-used later, we decide to *cache* it in a remote store which, to make things harder, can also potentially be slow, e.g.: it may suffer from latency spikes.

The application needs to serve the result to the end-user as soon as possible, so we both: 

* re-calculate the value, and 
* load the value from the store, 

in two different futures *in parallel*, and then:

* return the first value we get back,
* cancel the remaining future, in order to save time and resources.

Below is the code for such a scenario, which can be implemented using [`applyToEitherAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#applyToEitherAsync-java.util.concurrent.CompletionStage-java.util.function.Function-):

{% include collapsible_gist.html id="AsynchronousLongComputeVsSlowStore" gist_id="a760b98e2bb104fac9eb71336ef0dd69" %}

You can see that [`applyToEitherAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#applyToEitherAsync-java.util.concurrent.CompletionStage-java.util.function.Function-) is indeed triggered whenever either one of the two futures is done.

Note that [`CompletableFuture#cancel(boolean mayInterruptIfRunning)`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#cancel-boolean-), currently does not interrupt the targeted future, as per the Javadoc:

> mayInterruptIfRunning - this value has no effect in this implementation because interrupts are not used to control processing.

However, this is something you could definitely implement in your own [`CompletionStage<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletionStage.html).

Also note that exceptions are propagated immediately, and the callback function passed to [`applyToEitherAsync`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#applyToEitherAsync-java.util.concurrent.CompletionStage-java.util.function.Function-) is then never executed.
If this is undesirable behaviour, you can always chain [`whenComplete`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#whenComplete-java.util.function.BiConsumer-) to either the "failing future" or the "joining future".

## <span style="text-decoration: underline;">Example</span>: multi-stages computations and futures' synchronisation

In the next example, we perform a more complex computation for which we need to gather the intermediate results of all futures, and either aggregate these or compare them:

1. we asynchronously compute integers from 1 to 5 -- each integer generation takes 2 seconds
2. we sum these together
3. we asynchronously multiply the sum by 1, 2 and 3 -- each multiplication takes 2 seconds
4. we take the maximum.

Graphically, this would be represented as:

![sum=1+2+3+4+5; max=max(1sum,2sum,3sum)](/assets/img/java-8-concurrency-completablefuture-in-practice/call_tree_multistages.png "Computation tree: sum=1+2+3+4+5; max=max(1*sum,2*sum,3*sum)")
{: .text-center}

Let's see how we would implement this with `CompletableFuture`:

{% include collapsible_gist.html id="AsynchronousSumAndMax" gist_id="b136e1e488fc52da58d102df057265b1" %}

As you may have guessed, given we perform steps 1. (computing integers from 1 to 5) and 3. (multiplying the sum by 1, 2 and 3) asynchronously, the entire computation only takes 4 seconds, instead of 16 seconds if we were to perform the exact same computation using regular functions in one single thread.

Moreover, we synchronised futures and combined their intermediate results using various techniques:

* we summed integers from 1 to 5 using a *reducer*, combining the neutral element `CompletableFuture.completedFuture(0)` with other futures *as they completed* using `thenCombine`
* we *waited for all* multiplications to complete using `allOf` and `thenApply`-ed `Integer`'s natural order comparator to find the maximum value.

The resulting code is fairly clean, elegant and concise.


---------------

# Conclusion

We thoroughly explored [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)'s API using various concrete examples.

Hopefully, this:

* made it easier for you to understand the API and how to use it, 
* has convinced you of the usefulness of [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html),
* has made you more comfortable with asynchrony in general.

If you would rather read a bit more about [`CompletableFuture<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html), below is a selection of articles which may be useful.

Finally, feel free to reach out if you have any comment or question about this article, in the below "Comments" section.


---------------

# Other related articles

- Tomasz Nurkiewicz's [Java 8: Definitive guide to CompletableFuture](http://www.nurkiewicz.com/2013/05/java-8-definitive-guide-to.html) (also available on [DZone](https://dzone.com/articles/java-8-definitive-guide)).
- Dennis Sosnoski's [JVM concurrency: Java 8 concurrency basics](http://www.ibm.com/developerworks/library/j-jvmc2/index.html) on IBM developerWorks.
- Maurice Naftalin's [Functional-Style Callbacks Using Java 8's CompletableFuture](http://www.infoq.com/articles/Functional-Style-Callbacks-Using-CompletableFuture) on InfoQ.
- [Scala's futures and promises](http://docs.scala-lang.org/overviews/core/futures.html)



