## Suspend process and get stack trace

Run process with:

```
node --debug-brk myscript.js
```

Then:

```
$ node debug -p <pid_of_my_process>
debug> step
```

`step` should suspend the process.

```
debug> repl
> console.trace();
```

Source: [comment on node.js issue 25263](https://github.com/nodejs/node-v0.x-archive/issues/25263#issuecomment-105324658)
