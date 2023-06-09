---
id: introduction
title: Introduction to LIGO
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

LIGO is a programming language for writing [Tezos](https://tezos.com/)
smart contracts.  Smart contracts are a unique domain with extreme
resource constraints and even more extreme security risks. Unlike
desktop, mobile, or web application development, smart contracts
cannot rely on cheap CPU time and memory.  All resources used by
contracts are expensive, and tracked as 'gas costs'. Smart contracts
often directly control money or assets, which if stolen could rack up
to a large financial loss to the contracts controllers and
users. Tezos smart contracts live on the blockchain forever, if
there's a bug in them they can't be patched or amended. Naturally,
under these conditions, it's not possible to develop smart contracts
the way we're used to developing user-facing applications.

LIGO is designed with these problems in mind. The design philosophy
can be described in a few bullet points:

1. Make a clean, simple language with no unnecessary parts.

2. Offer multiple familiar syntaxes so users can get up and running quickly.

3. Encourage people to write simple code, so that it's easy to
formally verify the compiled output using a project like
[Mi-Cho-Coq](https://gitlab.com/nomadic-labs/mi-cho-coq/).

4. Significantly reduce the risk that your smart contract will lose
   its balance to an
   [avoidable exploit](https://www.wired.com/2016/06/50-million-hack-just-showed-dao-human/).

LIGO is a functional language designed to include the features you
need while avoiding patterns that make formal verification hard. Most
useful smart contracts can express their core functionality in under a
thousand lines of code. This makes them a good target for formal
methods, and what can't be easily proven can at least be extensively
tested. The simplicity of LIGO also keeps its compiled output
unbloated. Our hope is to have a simple, strongly typed language with
a low footprint.

LIGO currently offers two syntaxes:

  - **JsLIGO**, a TypeScript/JavaScript inspired syntax that aims to
    be familiar to those coming from TypeScript/JavaScript.

  - **CameLIGO**, an [OCaml](https://ocaml.org/) inspired
    syntax that allows you to write in a functional style.

Let's define some LIGO contract in the three flavours above. Do not
worry if it is a little confusing at first; we will explain all the
syntax in the upcoming sections of the documentation.

<Tabs
  defaultValue="jsligo"
  values={[
    { label: 'JsLIGO', value: 'jsligo', },
    { label: 'CameLIGO', value: 'cameligo', }
  ]
}>
<TabItem value="jsligo">

```jsligo group=a
type storage = int;

type parameter =
  ["Increment", int]
| ["Decrement", int]
| ["Reset"];

type return_ = [list<operation>, storage];

let main = (action: parameter, store: storage) : return_ => {
  return [
    list([]),
    match(action, {
      Increment: n => store + n,
      Decrement: n => store - n,
      Reset:     ()       => 0
    })
  ];
};
```

</TabItem>

<TabItem value="cameligo">

```cameligo group=a
type storage = int

type parameter =
  Increment of int
| Decrement of int
| Reset

type return = operation list * storage

let main (action, store : parameter * storage) : return =
  [],
  (match action with
     Increment n -> store + n
   | Decrement n -> store - n
   | Reset       -> 0)
```

</TabItem>
</Tabs>

This LIGO contract accepts the following LIGO expressions:
`Increment(n)`, `Decrement(n)` and `Reset`. Those serve as
`entrypoint` identification.

---

## Runnable code snippets

Some of the sections in this documentation will include runnable code snippets. Sources for those are available at
the [LIGO GitLab repository](https://gitlab.com/ligolang/ligo).

### Snippets

For example **code snippets** for the *Types* subsection of this doc, can be found here:
`gitlab-pages/docs/language-basics/src/types/**`

### Running snippets

In certain cases it makes sense to be able to run/evaluate the given snippet. Usually there will be an example command which you can use, such as:

```shell
ligo run evaluate-expr gitlab-pages/docs/language-basics/src/variables-and-constants/const.mligo --entry-point age -s cameligo
# Outputs: 25
```
